/******************************************************************
 * File Name    : decode.c
 * Description  : video decoder api
 * Author       : huangchengman <huangchengman@aee.com>
 * Date         : 2015-12-25
 ******************************************************************/

#ifndef __VIDDEC_H__
#define __VIDDEC_H__

#include "decode.h"

typedef struct VideoDec VideoDec;

VideoDec *VideoDec_Create(void);
int VideoDec_Destroy(VideoDec *dec);

typedef struct {
    int width;
    int height;

    int keyframe;

    int64_t pts;

    uint8_t *data;
    int size;
    int pkt_num;
} VideoPkt;

int VideoDec_Decode(VideoDec *dec, VideoPkt *inpkt, VideoFrame *frame);

#endif
