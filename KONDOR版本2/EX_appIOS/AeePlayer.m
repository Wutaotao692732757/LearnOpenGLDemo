
/******************************************************************
* File Name    : AeePlayer.c
* Description  : videoplayer interface
* Author       : huangchengman@aee.com
* Date         : 2016-04-12
******************************************************************/

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <sys/time.h>

#include "decode.h"
#include "AeePlayer.h"
#include "videorender.h"

#include "WTMoiveObject.h"

static DecodeCtx *g_dec_ctx;

static AEE_VIDEO_CONF config;
VideoFrame frame;
static int     last_width   = 0;
static int     last_height  = 0;
static int     last_picsize = 0;
static uint8_t last_picture[3 * 1024 * 1024];

static int wait_first_frame;

static void notify(int state, int streamState)
{
    OGCBDATA data;
    data.state       = state;
    data.streamState = streamState;
    data.statedata   = NULL;
//    config.CallbackFunc(&data);
}

static int64_t get_time(void)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);

    return (int64_t)tv.tv_sec * 1000 + (int64_t)tv.tv_usec / 1000;
}

static void init_last_picture(int width, int height)
{
    uint8_t *y = last_picture;
    uint8_t *u = y + width * height;
    uint8_t *v = u + width * height / 4;
    uint8_t *e = v + width * height / 4;    /* the end */

    memset(y, 0x35, u - y);
    memset(u, 0x7f, v - u);
    memset(v, 0x7f, e - v);

    last_picsize = (int)(e - y);
    last_width   = width;
    last_height  = height;
}

int AeePlayer_Config(AEE_VIDEO_CONF *conf)
{
    if(conf->height < 0 || conf->width < 0 || conf->x < 0 || conf->y < 0)
        return -1;

    config = *conf;
    gl_screen_set(0, 0, 1280, 720);
    if (!last_picsize)
        init_last_picture(config.width, config.height);

    notify(-1, -1);

    return 0;
}

int AeePlayer_SetUrl(char *pUrl)
{
//    gl_initialize();

    notify(1, 0);

    Decode_Init();
    g_dec_ctx = Decode_OpenStream(pUrl);
    if (!g_dec_ctx) {
        printf("openstream %s,failed!\n", pUrl);
        notify(-1, 0);
        return -1;
    }

    wait_first_frame = 1;

    return 0;
}


NSInteger loseCount;

int AeePlayer_RenderFrame()
{
//    if (wait_first_frame)
//        gl_render_frame(last_width, last_height, last_picture, last_picsize);

    
    if (Decode_ReadFrame(g_dec_ctx, &frame) <= 0) {
        loseCount++;
        
        NSLog(@"---丢失帧次数---%zd",loseCount);
        if (loseCount==10) {
            NSLog(@"----重置视频预览--PLEASE GO TO SETTING INTERFACE THEN GO BACK");
            [SVProgressHUD showErrorWithStatus:@"LOST CONNECTION PLEASE GO TO SETTING INTERFACE THEN GO BACK"];
            loseCount=0;
        }
//        gl_render_frame(last_width, last_height, last_picture, last_picsize);
//        NSLog(@"视频预览--%zd----%zd",last_width,last_height);
        
        return 0;
    }
    loseCount=0;
   
//    gl_render_frame(frame.width, frame.height, frame.data, frame.size);

//    if (wait_first_frame || last_width != frame.width || last_height != frame.height) {
//        memset(last_picture, 0x80, sizeof(last_picture));       /* gray background */
//        wait_first_frame = 0;
//    }
    displayYUV(&frame);
//    last_width   = frame.width;
//    last_height  = frame.height;
//    last_picsize = frame.size;
//    memcpy(last_picture, frame.data, frame.width * frame.height);     /* copy Y data only */

    return 0;
}

int AeePlayer_Destroy(void)
{
    if (g_dec_ctx)
    Decode_CloseStream(g_dec_ctx);
    Decode_Quit();
    gl_uninitialize();
    notify(1, 1);

    return 0;
}

int AeePlayer_SetState(int state)
{
    /* XXX: dummy */
    return 0;
}

int AeePlayer_GetVersion(char* version)
{
    char v[10]= "1.0.0";
    memcpy(version, v, sizeof(v));
    return 0;
}
