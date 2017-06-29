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


#define MAX_AUDIO_FRAME_SIZE 192000 // 1 second of 48khz 32bit audio

static  UInt8  *audio_chunk;
@interface WTMoiveObject ()

@property (nonatomic, copy) NSString *currtenPath;

@end

static id sharedPlayer;


@implementation WTMoiveObject{
    
    //输入视频的格式信息
    AVFormatContext     *WTFormatCtx;
    //输入视频的编码信息
    AVCodecContext     *WTCodecCtx;
    AVFrame             *WTFrame;
    //保存数据帧的数据结构
    AVStream            *stream;
    //解析文件读到的位置
    AVPacket            packet;
    AVPicture           picture;
    
    int                 videoStream;
    double              fps;
    BOOL                isReleaseResources;
    
    int                 frameFinished;

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
    if (WTFormatCtx!=nil&&_needReConnect==NO) return;
    if (_needReConnect==YES) {
        _needReConnect=NO;
        [self replaceTheResources:_currtenPath];
    }else{
        
        [self initializeResource:[moviePath UTF8String]];
        _currtenPath=moviePath;
    }
 
}

-(BOOL)initializeResource:(const char *)filePath{
   
    isReleaseResources = NO;
    AVCodec *pCodec;
    //注册所有解码器
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    //打开视频文件
    if (avformat_open_input(&WTFormatCtx, filePath, NULL, NULL) != 0) {
        
        UIAlertView *showView=[[UIAlertView alloc]initWithTitle:@"打开失败" message:@"打开失败了" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [showView show];
        goto initError;
    }
    
    if (avformat_find_stream_info(WTFormatCtx, NULL) <0 ) {
        
        UIAlertView *showView=[[UIAlertView alloc]initWithTitle:@"检查数据流失败" message:@"打开失败了" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [showView show];
        goto initError;
        
    }
    
    if ((videoStream = av_find_best_stream(WTFormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &pCodec, 0))<0) {
        UIAlertView *showView=[[UIAlertView alloc]initWithTitle:@"没有找到第一个视频流" message:@"打开失败了" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [showView show];
        goto initError;
        
    }

    //获取视频流的编解码上下文的指针
    stream = WTFormatCtx->streams[videoStream];
//            WTCodecCtx = stream->codec;
    WTCodecCtx=avcodec_alloc_context3(NULL);
    avcodec_parameters_to_context(WTCodecCtx, stream->codecpar);
    
//    avcodec_parameters_to_context(WTC);
    
    
    
//            WTParameters = stream->codecpar;
    //打印视频流的详细信息
    av_dump_format(WTFormatCtx, videoStream, filePath, 0);
    
    if (stream->avg_frame_rate.den && stream->avg_frame_rate.num) {
        fps = av_q2d(stream->avg_frame_rate);
    } else {
        fps = 30;
    }
    
    //查找解码器
    pCodec = avcodec_find_decoder(WTCodecCtx->codec_id);
    
    if (pCodec==NULL) {
        NSLog(@"没有找到解码器");
        goto initError;
    }
    // 打开解码器
    
    if (  avcodec_open2(WTCodecCtx, pCodec, NULL) <0) {
        NSLog(@"打开解码器失败");
        goto initError;
    }
    
    //分配视频帧
    WTFrame = av_frame_alloc();
    _outputWidth = WTCodecCtx->width;
    _outputHeight = WTCodecCtx->height;

    return YES;
    
initError:
    return NO;
    
}
-(BOOL)stepFrame {
    
    frameFinished =0;
    if(WTFrame==NULL) return 0;
    if (WTFormatCtx==NULL) {[_timer setFireDate:[NSDate distantFuture]];
        return 0;
    };
//  while    av_read_frame(WTFormatCtx, &packet) >=0
    if (av_read_frame(WTFormatCtx, &packet) >=0) {
    
//        if (packet.stream_index==videoStream) {
        
          avcodec_decode_video2(WTCodecCtx, WTFrame, &frameFinished, &packet);
            
//        }
    }
    av_packet_unref(&packet);

//    if (frameFinished==0&&isReleaseResources==NO) {
//        [self releaseResources];
//        
//    }
    return frameFinished !=0;
}


//开始播放方法
- (void)playWithImageView:(UIImageView *)imageView{
    _sourceImageView=imageView;
//    dispatch_queue_t que = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    
//    dispatch_async(que, ^{
//        
//        [self stepFrame];
//      
//    });
//    [self stepFrame];

    __weak typeof(self) weakSelf = self;
 _timer = [NSTimer scheduledTimerWithTimeInterval: 0.001
                                     target:weakSelf
                                   selector:@selector(displayNextFrame:)
                                   userInfo:nil
                                    repeats:YES];
    
}

-(void)displayNextFrame:(NSTimer *)timer {
   
    [self stepFrame];
    UIImage *currentImage=self.currentImage;
    if (currentImage!=nil) {
        _sourceImageView.image = currentImage;
    }
}

- (UIImage *)imageFromAVPicture
{

    avpicture_free(&picture);  //AV_PIX_FMT_RGB24
    avpicture_alloc(&picture, AV_PIX_FMT_RGB24, _outputWidth, _outputHeight);
    struct SwsContext * imgConvertCtx = sws_getContext(WTFrame->width,
                                                       WTFrame->height,
                                                       AV_PIX_FMT_YUV420P,
                                                       _outputWidth,
                                                       _outputHeight,
                                                       AV_PIX_FMT_RGB24,
                                                       SWS_BICUBIC,
                                                       NULL,
                                                       NULL,
                                                       NULL);
    
    if(imgConvertCtx == nil) return nil;
//     picture.data,
    
    if (WTFrame->data[0]==nil) return nil;
    
    
    if (WTFrame->data[0]==NULL||WTFrame->data[0]==0) return nil;
      
    const uint8_t *const *srcSlice = (const uint8_t *const *) WTFrame->data;
    
    if (srcSlice == 0) return nil;
    
    sws_scale(imgConvertCtx,
              srcSlice,
              WTFrame->linesize,
              0,
              WTFrame->height,
              picture.data,
              picture.linesize);
    sws_freeContext(imgConvertCtx);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault,
                                  picture.data[0],
                                  picture.linesize[0] * _outputHeight);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();  // 8  ,  24
    CGImageRef cgImage = CGImageCreate(_outputWidth,
                                       _outputHeight,
                                       8,
                                       24,
                                       picture.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CFRelease(data);

    return image;
}

#pragma mark --------------------------
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
    [self releaseResources];
    
}
//对相机操作之后-重新连接到新的预览
-(void)connectToNewStream{
    
    [self initializeResource:[_currtenPath UTF8String]];
     [_timer setFireDate:[NSDate distantPast]];
}
#pragma mark - 释放资源
- (void)releaseResources {
    //    SJLog(@"释放资源");
    //    SJLogFunc
    isReleaseResources = YES;
    // 释放RGB
    avpicture_free(&picture);
    // 释放frame
    av_packet_unref(&packet);
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
     stream=nil;
    
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
- (double)fps {
    return fps;
}

-(void)dealloc
{
    [_timer invalidate];
    [_voiceTimer invalidate];
    
    self.timer=nil;
}
@end



















