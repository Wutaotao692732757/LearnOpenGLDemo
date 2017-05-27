/******************************************************************
 * File Name    : decode.c
 * Description  : video decoder
 * Author       : huangchengman@aee.com
 * Date         : 2016-04-12
 ******************************************************************/
//#define ANDROID_APP
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/time.h>

#include <libavutil/imgutils.h>
#include <libavformat/avformat.h>

#include "viddec.h"
#include "decode.h"

#ifdef ANDROID_APP
#include <android/log.h>
#define LOGE(format, ...)  __android_log_print(ANDROID_LOG_ERROR, "VidDec", format, ##__VA_ARGS__)
#define LOGI(format, ...)  __android_log_print(ANDROID_LOG_INFO,  "VidDec", format, ##__VA_ARGS__)
#endif

struct VideoDec {
    AVCodec *codec;
    AVFrame *frame;
    AVCodecContext *dec_ctx;

    uint8_t *buffer;
    int      bufsiz;
    int      datsiz;

    int need_keyframe;
};

//test 
const char SPS_PPS[] =
{
	0x0, 0x0, 0x0, 0x1, 0x67, 0x64, 0x0, 0x28, 0xad, 0x84,
	0x5, 0x45, 0x62, 0xb8, 0xac, 0x54, 0x74, 0x20, 0x2a, 0x2b, 
	0x15, 0xc5, 0x62, 0xa3, 0xa1, 0x1, 0x51, 0x58, 0xae, 0x2b, 
	0x15, 0x1d, 0x8, 0xa, 0x8a, 0xc5, 0x71, 0x58, 0xa8, 0xe8, 
	0x40, 0x54, 0x56, 0x2b, 0x8a, 0xc5, 0x47, 0x42, 0x2, 0xa2, 
	0xb1, 0x5c, 0x56, 0x2a, 0x3a, 0x10, 0x24, 0x85, 0x21, 0x39, 
	0x3c, 0x9f, 0x27, 0xe4, 0xfe, 0x4f, 0xc9, 0xf2, 0x79, 0xb9, 
	0xb3, 0x4d, 0x8, 0x12, 0x42, 0x90, 0x9c, 0x9e, 0x4f, 0x93, 
	0xf2, 0x7f, 0x27, 0xe4, 0xf9, 0x3c, 0xdc, 0xd9, 0xa6, 0xb4, 
	0x2, 0x80, 0x2d, 0xc8, 0x0, 0x0, 0x0, 0x1, 0x68, 0xee, 0x3c, 0xb0
};

static int64_t get_time(void)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);

    return (int64_t)tv.tv_sec * 1000 + (int64_t)tv.tv_usec / 1000;
}

VideoDec *VideoDec_Create(void)
{
    av_register_all();
    avformat_network_init();

    VideoDec *dec = (VideoDec *)malloc(sizeof(VideoDec));
    if (!dec)
        return NULL;
    memset(dec, 0, sizeof(VideoDec));

    dec->codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    //dec->codec = avcodec_find_decoder(AV_CODEC_ID_MPEG4);
    if (!dec->codec)
        goto fail;

    dec->dec_ctx = avcodec_alloc_context3(dec->codec);
    //some rtsp stream no sps_pps info
    dec->dec_ctx->extradata = malloc( 128 * sizeof(char));
    memset(dec->dec_ctx->extradata, 0, sizeof(SPS_PPS));
    memcpy(dec->dec_ctx->extradata, SPS_PPS, sizeof(SPS_PPS));
    dec->dec_ctx->extradata_size = sizeof(SPS_PPS);
    printf("extradata size :%d\n", sizeof(SPS_PPS));
    if (!dec->dec_ctx)
        goto fail;

    if (avcodec_open2(dec->dec_ctx, dec->codec, NULL) < 0)
        goto fail;

    dec->frame = av_frame_alloc();
    if (!dec->frame)
        goto fail;

    dec->need_keyframe = 1;

    return dec;

fail:
    if (dec->frame)
        av_frame_free(&dec->frame);
    if (dec->dec_ctx)
        avcodec_close(dec->dec_ctx);
    if (dec->buffer)
        free(dec->buffer);
    free(dec);

    return NULL;
}

int VideoDec_Destroy(VideoDec *dec)
{
    if (dec->frame)
        av_frame_free(&dec->frame);
    if (dec->dec_ctx)
        avcodec_close(dec->dec_ctx);
    if (dec->buffer)
        free(dec->buffer);
    free(dec);

    return 0;
}

static int get_video_frame(VideoDec *dec, AVFrame *frame, VideoFrame *vf)
{
    int bufsize = av_image_get_buffer_size(frame->format, frame->width, frame->height, 1);

    if (!vf->data || vf->opaque < bufsize) {
        if (vf->data)
            free(vf->data);
        vf->data   = malloc(bufsize);
        vf->opaque = bufsize;
    }

    if (!vf->data)
        return -1;

    vf->size = bufsize;

    av_image_copy_to_buffer(vf->data, bufsize, (const uint8_t **)(frame->data),
                frame->linesize, frame->format, frame->width, frame->height, 1);

    vf->width  = frame->width;
    vf->height = frame->height;
    vf->pts    = frame->pkt_pts;

    return 0;
}

int VideoDec_Decode(VideoDec *dec, VideoPkt *inpkt, VideoFrame *frame)
{
    AVPacket pkt = {
        .pts   = inpkt->pts,
        .data  = inpkt->data,
        .size  = inpkt->size,
        .flags = inpkt->keyframe ? AV_PKT_FLAG_KEY : 0,
    };
    //LOGI("--->to decode,pkt num:%d,pkt size:%d \n",inpkt->pkt_num, inpkt->size);
    int got_frame = 0;

    if (avcodec_decode_video2(dec->dec_ctx, dec->frame, &got_frame, &pkt) < 0){
	printf("decode failed!\n");
        return -1;
    }
//    AVPacket *npkt=&pkt;
//    av_packet_free(&npkt);
//    av_free_packet(&pkt);
    av_packet_unref(&pkt);
    if (got_frame) {
        get_video_frame(dec, dec->frame, frame);
	//LOGI("--->decoded pkt num:%d",inpkt->pkt_num);
        return 1;
    }
   
    return 0;
}
