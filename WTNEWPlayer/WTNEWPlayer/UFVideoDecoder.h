//
//  UFVideoDecoder.h
//  EX_appIOS
//
//  Created by wutaotao on 2017/6/5.
//  Copyright © 2017年 aee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
 
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>

@protocol WTDecoderDelegate <NSObject>

@optional
-(void)getDecodeImageData:(CVImageBufferRef)imageBuffer;

@end



@interface UFVideoDecoder : NSObject
- (void)decodeWithCodec:(AVCodecContext *)codec packet:(AVPacket)packet;

@property(nonatomic,weak)id<WTDecoderDelegate>delegate;

@end
