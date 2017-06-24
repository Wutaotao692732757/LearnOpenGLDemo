//
//  AGLKContext.h
//  ch6-2
//
//  Created by wutaotao on 2017/6/24.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext
{
    GLKVector4 clearColor;
}

@property (nonatomic,assign,readwrite) GLKVector4 clearColor;

-(void)clear:(GLbitfield)mask;
-(void)enable:(GLenum)capability;
-(void)disable:(GLenum)capability;

-(void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor;

@end
