/******************************************************************
 * File Name    : decode.c
 * Description  : video decoder
 * Author       : huangchengman@aee.com
 * Date         : 2016-06-12
 ******************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/time.h>

#include "queue.h"
#include "decode.h"
#include "viddec.h"
#include "videosink.h"

#define BUFFERED_RAWFRAME_NUMBER   (32)
#define BUFFERED_YUVFRAME_NUMBER   (2)

#ifdef ANDROID_APP
#define TAG "VideoDec"
#include <android/log.h>
#define LOGE(format, ...)  __android_log_print(ANDROID_LOG_ERROR, TAG, format, ##__VA_ARGS__)
#define LOGI(format, ...)  __android_log_print(ANDROID_LOG_INFO,  TAG, format, ##__VA_ARGS__)
#endif

struct DecodeCtx {
    char url[1024];

    int64_t pts_base;
    int64_t timebase;

    Queue *fullq;
    Queue *emptyq;

    VideoSink *videosink;
    VideoDec *viddec;

    pthread_t decode_tid;

    int abort;

    uint8_t *buffer;
    uint8_t bufsiz;
};

static int64_t get_time(void)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);

    return (int64_t)tv.tv_sec * 1000 + (int64_t)tv.tv_usec / 1000;
}

static VideoFrame *obtain_empty_frame(DecodeCtx *ctx)
{
    VideoFrame *vf = NULL;

    int i;
    for (i = 0; i < 2; i++) {
        vf = queue_remove(ctx->emptyq, 10);
        if (vf)
            return vf;

        vf = queue_remove(ctx->fullq, 0);
        if (vf) {
            return vf;
        }
    }

    return NULL;
}

static void *video_decode_thread(void *arg)
{
    DecodeCtx *ctx = (DecodeCtx *)arg;

    int need_keyframe = 1;

    //FILE *fp = fopen("/sdcard/raw.yuv", "aw+");
    while (!ctx->abort) {
        if (VideoSink_NumberFrameBuffered(ctx->videosink) > BUFFERED_RAWFRAME_NUMBER &&
            VideoSink_HasKeyFrameBuffered(ctx->videosink))
            need_keyframe = 1;

        VideoPkt inpkt;

        int ret = VideoSink_ReadStream(ctx->videosink, &inpkt, 100);
	//LOGI("--->send pkt to decode,pkt num:%d, pkt size:%d,pkt pts:%lld \n",inpkt.pkt_num, inpkt.size, inpkt.pts);
        if (ret < 0)
            break;
        else if (ret == 0)
            continue;

        if (need_keyframe && !inpkt.keyframe)
            continue;

        if (inpkt.keyframe)
            need_keyframe = 0;

        VideoFrame *frame = obtain_empty_frame(ctx);
        if (!frame)
            continue;

        if (VideoDec_Decode(ctx->viddec, &inpkt, frame) <= 0) {
            queue_insert(ctx->emptyq, frame, 100);
#ifdef ANDORID_APP
	    LOGE("decode failed! \n");
#endif
            continue;
        }
   	// LOGI("--->decode end ");
        //fwrite(frame->data, frame->size, 1, fp);
        queue_insert(ctx->fullq, frame, 100);
    }
    //fclose(fp);
    return 0;
}

int Decode_Init(void)
{
    VideoSink_Init();

    return 0;
}

int Decode_Quit(void)
{
    VideoSink_Quit();

    return 0;
}

static int close_stream(DecodeCtx *ctx)
{
    ctx->abort = 1;

    if (ctx->decode_tid)
        pthread_join(ctx->decode_tid, NULL);

    VideoSink_CloseStream(ctx->videosink);
    VideoDec_Destroy(ctx->viddec);

    if (ctx->fullq) {
        VideoFrame *vf;
        while ((vf = queue_remove(ctx->fullq, 0)) != NULL) {
            if (vf->data)
                free(vf->data);
            free(vf);
        }
        queue_destroy(ctx->fullq);
    }

    if (ctx->emptyq) {
        VideoFrame *vf;
        while ((vf = queue_remove(ctx->emptyq, 0)) != NULL) {
            if (vf->data)
                free(vf->data);
            free(vf);
        }
        queue_destroy(ctx->emptyq);
    }

    if (ctx->buffer)
        free(ctx->buffer);

    free(ctx);

    return 0;
}

static int is_localhost(char *url)
{
    /*if (strstr(url, "rtsp://127.0.0.1"))
        return 1;
    if (strstr(url, "rtsp://localhost"))
        return 1;*/
    return 0;
}

DecodeCtx *Decode_OpenStream(char *url)
{
    DecodeCtx *ctx = (DecodeCtx *)malloc(sizeof(DecodeCtx));
    if (!ctx)
        return NULL;
    memset(ctx, 0, sizeof(DecodeCtx));

    ctx->videosink = VideoSink_OpenStream(url);
    if (!ctx->videosink)
        goto fail;

    ctx->viddec = VideoDec_Create();
    if (!ctx->viddec)
        goto fail;

    ctx->fullq  = queue_create(BUFFERED_YUVFRAME_NUMBER);
    if (!ctx->fullq)
        goto fail;

    ctx->emptyq = queue_create(BUFFERED_YUVFRAME_NUMBER);
    if (!ctx->emptyq)
        goto fail;

    int i;
    for (i = 0; i < BUFFERED_YUVFRAME_NUMBER; i++) {
        VideoFrame *vf = malloc(sizeof(VideoFrame));
        if (!vf)
            goto fail;
        memset(vf, 0, sizeof(VideoFrame));

        queue_insert(ctx->emptyq, vf, 100);
    }

    ctx->pts_base = -1;
    ctx->timebase = -1;

    strncpy(ctx->url, url, sizeof(ctx->url) - 1);

    pthread_create(&ctx->decode_tid, NULL, video_decode_thread, ctx);

    return ctx;

fail:
    close_stream(ctx);
    return NULL;
}

static void *close_proxy(void *arg)
{
    pthread_detach(pthread_self());

    DecodeCtx *ctx = (DecodeCtx *)arg;
    if (!ctx)
        return NULL;

    close_stream(ctx);

    return NULL;
}

int Decode_CloseStream(DecodeCtx *ctx)
{
    pthread_t tid;
    pthread_create(&tid, NULL, close_proxy, ctx);
    return 0;
}

static int64_t needwait(DecodeCtx *ctx, int64_t pts)
{
    if (ctx->pts_base == -1 || ctx->pts_base > pts) {
        ctx->pts_base = pts;
        ctx->timebase = get_time();
    }

    double itv_pts = pts - ctx->pts_base;
    int64_t next_t = itv_pts / 90000 * 1000 + ctx->timebase;

    int64_t time_ms = next_t - get_time();
    if (time_ms < 50 && time_ms >= 0)
        return time_ms;

    ctx->pts_base = pts;
    ctx->timebase = get_time();

    return 0;
}

int Decode_ReadFrame(DecodeCtx *ctx, VideoFrame *frame)
{
    int64_t t1 = get_time();

    VideoFrame *vf = queue_remove(ctx->fullq, 1000);
    if (!vf){
	//LOGE("no decoded frame!\n");
        return 0;
    }
    int64_t t2 = get_time();

    if (!ctx->buffer || ctx->bufsiz < vf->size) {
        if (ctx->buffer)
            free(ctx->buffer);
        ctx->buffer = malloc(vf->size);
        ctx->bufsiz = vf->size;
    }

    memcpy(ctx->buffer, vf->data, vf->size);

    memset(frame, 0, sizeof(VideoFrame));
    frame->width  = vf->width;
    frame->height = vf->height;
    frame->pts    = vf->pts;
    frame->data   = ctx->buffer;
    frame->size   = vf->size;

    queue_insert(ctx->emptyq, vf, 1000);

    int time_ms = (int)needwait(ctx, frame->pts);
    if (time_ms > 0){
	//LOGI("video frame delay time:%d(ms)\n",time_ms);
        usleep(time_ms * 1000);
    }

    return 1;
}
