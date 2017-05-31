//
//  AGLKContext.m
//  ch6-4
//
//  Created by wutaotao on 2017/5/31.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext

-(void)setClearColor:(GLKVector4)clearColor
{
    _clearColor = clearColor;
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    
}

-(void)clear:(GLbitfield)mask
{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    glClear(mask);
}

-(void)enable:(GLenum)capability
{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    glEnable(capability);
}

-(void)disable:(GLenum)capability
{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    glDisable(capability);
}

-(void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor
{
    glBlendFunc(sfactor, dfactor);
}


@end
