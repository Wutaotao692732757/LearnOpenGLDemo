//
//  WTVIDEOPLAYER.m
//  WTNEWPlayer
//
//  Created by wutaotao on 2017/6/5.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "WTVIDEOPLAYER.h"
#import "UFVideoDecoder.h"

@interface WTVIDEOPLAYER ()<WTDecoderDelegate>
{
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
}
@property (nonatomic, copy) NSString *currtenPath;

@property (nonatomic,strong)UFVideoDecoder *videoDecoder;
@end

@implementation WTVIDEOPLAYER

-(instancetype)initWithVideo:(NSString *)moviePath
{
    if (!(self=[super init])) return nil;
    
    if ([self initializeResource:[moviePath UTF8String]]) {
        
        self.currtenPath=[moviePath copy];
        
        return self;
    }else{
        
        return nil;
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
    //        WTCodecCtx = stream->codec;
    WTCodecCtx=avcodec_alloc_context3(NULL);
//    avcodec_parameters_to_context(WTCodecCtx, stream->codecpar);
    WTCodecCtx = WTFormatCtx->streams[videoStream]->codec;
    //        WTParameters = stream->codecpar;
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
    
    if(pCodec->type==AVMEDIA_TYPE_AUDIO){
        NSLog(@"shengyinshengyinshengyin");
    };
    
   
    return YES;
    
initError:
    return NO;
    
}

-(void)getDecodeImageData:(CVImageBufferRef)imageBuffer
{
    NSLog(@"获取到了图像!!");
}
NSMutableData *readdata;
-(void)decodeFrame{
    
    readdata = [NSMutableData data];
   [NSTimer scheduledTimerWithTimeInterval:0.03 repeats:YES block:^(NSTimer * _Nonnull timer) {
//         WTCodecCtx = WTFormatCtx->streams[videoStream]->codec;
        if (av_read_frame(WTFormatCtx, &packet) >=0) {
            if (packet.stream_index == videoStream) {
            [self.videoDecoder decodeWithCodec:WTCodecCtx packet:packet];
            
//            NSData *data = [NSData dataWithBytes:packet.data length:packet.size];
//            
//            [readdata appendData:data];
//                
//                if (readdata.length>=1024*1024) {
//                    
//                    NSString *path_sandox = NSHomeDirectory();
//                    //设置一个图片的存储路径
//                    NSString *dataPath = [path_sandox stringByAppendingString:@"/Documents/test.h264"];
//                    
//                    [readdata writeToFile:dataPath atomically:YES];
//                    readdata.length=0;
//                }
                //            NSLog(@"路径-- %@",dataPath);
//            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSLog(@"%@", data);
            }
        }
    }];
}

-(UFVideoDecoder *)videoDecoder
{
    if (_videoDecoder==nil) {
        _videoDecoder=[[UFVideoDecoder alloc]init];
        _videoDecoder.delegate=self;
        _videoDecoder.lyOpenGLView = self.lyOpenGLView;
     
    }
    return _videoDecoder;
}





@end
