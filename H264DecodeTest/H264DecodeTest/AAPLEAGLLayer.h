//
//  AAPLEAGLLayer.h
//  H264DecodeTest
//
//  Created by wutaotao on 2017/6/7.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <QuartzCore/QuartzCore.h>
#include <CoreVideo/CoreVideo.h>

@interface AAPLEAGLLayer : CAEAGLLayer

@property CVPixelBufferRef pixelBuffer;

-(id)initWithFrame:(CGRect)frame;
-(void)resetRenderBuffer;

@end
