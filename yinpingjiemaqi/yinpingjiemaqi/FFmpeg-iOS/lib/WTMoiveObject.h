//
//  WTMoiveObject.h
//  ffmpegTest
//
//  Created by 伍陶陶 on 2016/10/28.
//  Copyright © 2016年 伍陶陶. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTMoiveObject : NSObject

@property(nonatomic,strong,readonly)UIImage *currentImage;
@property(nonatomic,assign,readonly)int sourceWidth, sourceHeight;
// 输出图像大小。默认设置为源大小。
@property (nonatomic,assign) int outputWidth, outputHeight;

// 视频的长度，秒为单位
@property (nonatomic, assign, readonly) double duration;

//视频的当前秒数
@property (nonatomic, assign, readonly) double currentTime;


//用于播放的视图
@property (nonatomic,strong)UIImageView *sourceImageView;
//定时器
@property (nonatomic,strong) NSTimer *timer;
//音频定时器  可以减少延迟
@property (nonatomic,strong) NSTimer *voiceTimer;

/* 初始化视频播放器。 */
+ (instancetype)sharedPlayer;
//设置路径

-(void)setVideoPathWithString:(NSString *)moviePath;
/* 开始播放 */
- (void)playWithImageView:(UIImageView *)imageView;

/* 停止播放 */
-(void)StopPlay;
/*继续播放*/
-(void)PlayerContinue;

/*退出流模式----重新连接流信息之前必须*/
-(void)getOutStream;
//对相机操作之后-重新连接到新的预览
-(void)connectToNewStream;

//是否需要重连---配合相机CamerTool使用的参数，当发送下载，加载相机相片的请求之后重新进入预览界面需要重新连接流信息
@property(nonatomic,assign) BOOL needReConnect;

/* 切换资源 */
- (void)replaceTheResources:(NSString *)moviePath;


@end
