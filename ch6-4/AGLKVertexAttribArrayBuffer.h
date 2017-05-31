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


@interface AGLKVertexAttribArrayBuffer : NSObject{
    GLsizeiptr stride;
    GLsizeiptr bufferSizeBytes;
    GLuint name;
}

@property (nonatomic,readonly) GLuint name;
@property (nonatomic,readonly) GLsizeiptr bufferSizeBytes;
@property (nonatomic,readonly) GLsizeiptr stride;

+(void)drawPreparedArraysWithmode:(GLenum)mode startVertexIndex:(GLint)first
                 numberOfVertices:(GLsizei)count;

-(id)initWithAttribStride:(GLsizeiptr)stride
         numberOfVertices:(GLsizei)count
                    bytes:(const GLvoid *)dataptr
                    usage:(GLenum)usage;
-(void)prepareToDrawWithAttrib:(GLuint)index
           numberOfCoordinates:(GLint)count
                  attribOffset:(GLsizeiptr)offset
                  shouldEnable:(BOOL)shouldEnable;
-(void)drawArrayWithMode:(GLenum)mode
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count;

-(void)reinitWithAttribStride:(GLsizeiptr)stride
             numberOfVertices:(GLsizei)count
                        bytes:(const GLvoid*)dataptr;


@end
