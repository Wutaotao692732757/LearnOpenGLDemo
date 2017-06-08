//
//  VideoFileParser.h
//  H264DecodeTest
//
//  Created by wutaotao on 2017/6/7.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <objc/NSObject.h>

@interface VideoPacket : NSObject

@property uint8_t * buffer;
@property NSInteger size;

@end


@interface VideoFileParser : NSObject

-(BOOL)open:(NSString *)fileName;
-(VideoPacket *)nextPacket;
-(void)close;

@end
