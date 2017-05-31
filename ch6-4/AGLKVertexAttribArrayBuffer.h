//
//  AGLKVertexAttribArrayBuffer.h
//  ch6-4
//
//  Created by wutaotao on 2017/5/31.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <GLKit/GLKit.h>

@class AGLKElementIndexArrayBuffer;

typedef enum {
    AGLKVertexAttribPosition = GLKVertexAttribPosition,
    AGLKVertexAttribNormal = GLKVertexAttribNormal,
    AGLKVertexAttribColor = GLKVertexAttribColor,
    AGLKVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    AGLKVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
} AGLKVertexAttrib;


@interface AGLKVertexAttribArrayBuffer : NSObject

@end
