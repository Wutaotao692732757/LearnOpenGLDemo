//
//  WTVIDEOPLAYER.h
//  WTNEWPlayer
//
//  Created by wutaotao on 2017/6/5.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
#import <UIKit/UIKit.h>

@interface WTVIDEOPLAYER : NSObject
@property (nonatomic,assign) int outputWidth, outputHeight;
-(instancetype)initWithVideo:(NSString *)moviePath;

-(void)decodeFrame;
@end
