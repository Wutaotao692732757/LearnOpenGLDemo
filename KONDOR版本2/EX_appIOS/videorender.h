/******************************************************************
 * File Name    : videorender.h
 * Description  : video render interface
 * Author       : huangchengman@aee.com
 * Date         : 2016-04-12
 ******************************************************************/

#ifndef __VIDEORENDER_H__
#define __VIDEORENDER_H__

void gl_initialize(void);
void gl_uninitialize(void);
void gl_render_frame(int width, int height, uint8_t *buf, int len);

void gl_screen_set(int screen_x, int screen_y, int screen_width, int screen_height);
void gl_viewsize_set(int width, int height);
void gl_imagesize_set(int width, int height);

#endif
