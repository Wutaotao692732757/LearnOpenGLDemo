//
//  ViewController.m
//  yinpingjiemaqi
//
//  Created by wutaotao on 2017/6/29.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswresample/swresample.h>
@interface ViewController ()

@end
#define MAX_AUDIO_FRAME_SIZE 192000 // 1 second of 48khz 32bit audio
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVFormatContext *pFormatCtx;
    int             i, audioStream;
    AVCodecContext  *pCodecCtx;
    AVCodec         *pCodec;
    AVPacket        *packet;
    uint8_t         *out_buffer;
    AVFrame         *pFrame;
    int ret;
    uint32_t len = 0;
    int got_picture;
    int index = 0;
    int64_t in_channel_layout;
    struct SwrContext *au_convert_ctx;
   const char *source  =  [[[NSBundle mainBundle] pathForResource:@"test" ofType:@"pcm"]  UTF8String];
    
    
    FILE *pFile=fopen(source, "wb");
   const char *url=[@"rtsp://192.168.42.1/live" UTF8String];
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    pFormatCtx = avformat_alloc_context();
    //Open
    if(avformat_open_input(&pFormatCtx,url,NULL,NULL)!=0){
        printf("Couldn't open input stream.\n");
        return   ;
    }
    // Retrieve stream information
    if(avformat_find_stream_info(pFormatCtx,NULL)<0){
        printf("Couldn't find stream information.\n");
        return  ;
    }
    // Dump valid information onto standard error
    av_dump_format(pFormatCtx, 0, url, false);
    
    // Find the first audio stream
    audioStream=-1;
    for(i=0; i < pFormatCtx->nb_streams; i++)
        if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO){
            audioStream=i;
            break;
        }
    
    if(audioStream==-1){
        printf("Didn't find a audio stream.\n");
        return  ;
    }
    
    // Get a pointer to the codec context for the audio stream
    pCodecCtx=pFormatCtx->streams[audioStream]->codec;
    
    // Find the decoder for the audio stream
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec==NULL){
        printf("Codec not found.\n");
        return  ;
    }
    
    // Open codec
    if(avcodec_open2(pCodecCtx, pCodec,NULL)<0){
        printf("Could not open codec.\n");
        return  ;
    }
    
    packet=(AVPacket *)av_malloc(sizeof(AVPacket));
    av_init_packet(packet);
    
    //Out Audio Param
    uint64_t out_channel_layout=AV_CH_LAYOUT_STEREO;
    //nb_samples: AAC-1024 MP3-1152
    int out_nb_samples=pCodecCtx->frame_size;
    enum AVSampleFormat out_sample_fmt=AV_SAMPLE_FMT_S16;
    int out_sample_rate=44100;
    int out_channels=av_get_channel_layout_nb_channels(out_channel_layout);
    //Out Buffer Size
    int out_buffer_size=av_samples_get_buffer_size(NULL,out_channels ,out_nb_samples,out_sample_fmt, 1);
    
    out_buffer=(uint8_t *)av_malloc(MAX_AUDIO_FRAME_SIZE*2);
    pFrame=av_frame_alloc();
    
    //FIX:Some Codec's Context Information is missing
    in_channel_layout=av_get_default_channel_layout(pCodecCtx->channels);
    //Swr
    au_convert_ctx = swr_alloc();
    au_convert_ctx=swr_alloc_set_opts(au_convert_ctx,out_channel_layout, out_sample_fmt, out_sample_rate,
                                      in_channel_layout,pCodecCtx->sample_fmt , pCodecCtx->sample_rate,0, NULL);
    swr_init(au_convert_ctx);
    
    while(av_read_frame(pFormatCtx, packet)>=0){
        if(packet->stream_index==audioStream){
            
            ret = avcodec_decode_audio4( pCodecCtx, pFrame,&got_picture, packet);
            if ( ret < 0 ) {
                printf("Error in decoding audio frame.\n");
                return  ;
            }
            if ( got_picture > 0 ){
                swr_convert(au_convert_ctx,&out_buffer, MAX_AUDIO_FRAME_SIZE,(const uint8_t **)pFrame->data , pFrame->nb_samples);
                
                printf("index:%5d\t pts:%lld\t packet size:%d\n",index,packet->pts,packet->size);
                //Write PCM
//                fwrite(out_buffer, 1, out_buffer_size, pFile);
                
                
                
                
                
                
                index++;
            }
        }
        av_free_packet(packet);
    }
    
    swr_free(&au_convert_ctx);
    
    fclose(pFile);
    
    av_free(out_buffer);
    // Close the codec
    avcodec_close(pCodecCtx);
    // Close the video file  
    avformat_close_input(&pFormatCtx);



}




@end
