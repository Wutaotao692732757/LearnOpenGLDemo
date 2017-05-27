/******************************************************************
 * File Name    : decode.c
 * Description  : video decoder
 * Author       : huangchengman <huangchengman@aee.com>
 * Date         : 2015-12-23
 ******************************************************************/

#ifndef __DECODE_H__
#define __DECODE_H__

int Decode_Init(void);
int Decode_Quit(void);

typedef struct DecodeCtx DecodeCtx;

DecodeCtx *Decode_OpenStream(char *url);
int Decode_CloseStream(DecodeCtx *ctx);

typedef struct {
    int width;
    int height;

    long opaque;
    int64_t pts;

    int keyframe;

    uint8_t *data;
    int      size;
} VideoFrame;

int Decode_ReadFrame(DecodeCtx *ctx, VideoFrame *frame);

#endif
