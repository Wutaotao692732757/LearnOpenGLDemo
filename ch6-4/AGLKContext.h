//
//  AGLKContext.h
//  ch6-4
//
//  Created by wutaotao on 2017/5/31.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


@interface AGLKContext : EAGLContext

@property(nonatomic,assign,readwrite) GLKVector4 clearColor;

-(void)clear:(GLbitfield)mask;
-(void)enable:(GLenum)capability;
-(void)disable:(GLenum)capability;

-(void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor;

@end
