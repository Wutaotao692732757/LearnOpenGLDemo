//
//  WTMoiveObject.m
//  ffmpegTest
//
//  Created by 伍陶陶 on 2016/10/28.
//  Copyright © 2016年 伍陶陶. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTMoiveObject.h"
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import "OpenGLView20.h"
  OpenGLView20 *glView;
static id sharedPlayer;
#define MAX_AUDIO_FRAME_SIZE 192000 // 1 second of 48khz 32bit audio

@interface AVPACKObject : NSObject
@property (nonatomic,assign)AVPacket *pack;

@end
@implementation AVPACKObject


@end

@interface AVFRAMEObect : NSObject

@property (nonatomic,assign)AVFrame *frame;
@end
@implementation AVFRAMEObect


@end

static  UInt8  *audio_chunk;
@interface WTMoiveObject ()

@property (nonatomic, copy) NSString *currtenPath;
@property (nonatomic,assign)BOOL reading;

//视频帧缓存
@property (atomic,strong)NSMutableArray *picArr;
//解码缓存
@property (atomic,strong)NSMutableArray *decodeARR;

@property (nonatomic,strong)UIImage *oneImage;
@end



@implementation WTMoiveObject{
    
    //输入视频的格式信息
    AVFormatContext     *WTFormatCtx;
    //输入视频的编码信息
    AVCodecContext     *WTCodecCtx;
    AVFrame             *WTFrame;
    BOOL isReleaseResources;
    
}

+ (instancetype)sharedPlayer{
    if(sharedPlayer==nil){
        @synchronized (self) {
       sharedPlayer=[[WTMoiveObject alloc]init];
        }
    }
    return sharedPlayer;
}

-(void)setVideoPathWithString:(NSString *)moviePath
{
    if ([_currtenPath isEqualToString:moviePath]) return;
    [self initializeResource:[moviePath UTF8String]];
    _currtenPath=moviePath;
  
}

-(BOOL)initializeResource:(const char *)filePath{
 
    AeePlayer_SetUrl(filePath);
 
    return NO;
    
}



//开始播放方法
- (void)playWithImageView:(UIImageView *)imageView{
    _sourceImageView=imageView;
   
        [glView removeFromSuperview];
    
    CGRect imgrect = CGRectMake(0, 0, ScreenW, (432.0/768.0)*ScreenW);
    
        glView = [[OpenGLView20 alloc] initWithFrame:imgrect];
        [imageView addSubview:glView];
        //设置视频原始尺寸
        [glView setVideoSize:imgrect.size.width height:imgrect.size.height];
    //0.01
        [_timer invalidate];
        _timer=nil;
        _timer = [weakTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(displayNextFrame:) userInfo:nil repeats:YES];
 
}

void displayYUV(VideoFrame* frame){
    
    NSLog(@"-----------渲染YUV");
    
    if (frame->data==nil) return;
    
    OpenGLView20 *nglView=glView;
    [nglView displayYUV420pData:frame->data width:frame->width height:frame->height];
    
}


-(void)displayNextFrame:(weakTimer *)timer {
    
     AeePlayer_RenderFrame();
 
}
unsigned char temp; unsigned char *pic;  char firstObject;

- (UIImage *)imageFromAVPicture
{
    //亮度减半
 
    if (WTFormatCtx==nil) return nil;
    
    if (WTFrame->data[0]==nil) return nil;

    
        [glView displayYUV420pData:WTFrame width:_outputWidth height:_outputHeight];
      return self.oneImage;
}

#pragma mark -------------------------------------------------
//结束播放方法
-(void)StopPlay{
 
    [_timer setFireDate:[NSDate distantFuture]];
 
 
}
-(void)PlayerContinue{
 
    [_timer setFireDate:[NSDate distantPast]];
}
/*退出流模式----重新连接流信息之前必须*/
-(void)getOutStream{
 
  [_timer setFireDate:[NSDate distantFuture]];
 
    
}
//对相机操作之后-重新连接到新的预览
-(void)connectToNewStream{
     [_timer setFireDate:[NSDate distantPast]];
 
}
#pragma mark - 释放资源
- (void)releaseResources {
 
    // 释放YUV frame
    av_free(WTFrame);
    // 关闭解码器
    if (WTCodecCtx) avcodec_close(WTCodecCtx);
    // 关闭文件
    if (WTFormatCtx) avformat_close_input(&WTFormatCtx);
    avformat_network_deinit();
    
    WTFormatCtx=nil;
    WTCodecCtx=nil;
    WTFrame=nil;
 
    
}

- (void)replaceTheResources:(NSString *)moviePath {
    if (!isReleaseResources) {
        [self releaseResources];
    }
    self.currtenPath = [moviePath copy];
    [self initializeResource:[moviePath UTF8String]];
}

- (void)redialPaly {
    [self initializeResource:[self.currtenPath UTF8String]];
}

-(void)setOutputWidth:(int)newValue {
    if (_outputWidth == newValue) return;
    _outputWidth = newValue;
}
-(void)setOutputHeight:(int)newValue {
    if (_outputHeight == newValue) return;
    _outputHeight = newValue;
}
-(UIImage *)currentImage {
    
    
    if (WTFrame==nil) return nil;
    
    if (!WTFrame->data[0]) return nil;
    return [self imageFromAVPicture];
}
-(double)duration {
    return (double)WTFormatCtx->duration / AV_TIME_BASE;
}

- (int)sourceWidth {
    return WTCodecCtx->width;
}
- (int)sourceHeight {
    return WTCodecCtx->height;
}

-(NSMutableArray *)decodeARR{
    if (_decodeARR==nil) {
        _decodeARR=[NSMutableArray array];
    }
    return _decodeARR;
}

-(NSMutableArray *)picArr
{
    if (_picArr==nil) {
        _picArr=[NSMutableArray array];
    }
    return _picArr;
}

-(UIImage *)oneImage
{
    if (_oneImage==nil) {
        _oneImage=[[UIImage alloc]init];
    }
    return _oneImage;
}



-(void)dealloc
{
    [glView clearFrame];
    [_timer setFireDate:[NSDate distantFuture]];
    [_voiceTimer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    [_voiceTimer invalidate];
    
    self.timer=nil;
}
@end



















