//
//  AGLKTextureTransformBaseEffect.h
//  ch6-4
//
//  Created by wutaotao on 2017/5/31.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKTextureTransformBaseEffect : GLKBaseEffect

@property(atomic,assign) GLKVector4 light0Position;
@property(atomic,assign) GLKVector3 light0SpotDirection;
@property(atomic,assign) GLKVector4 light1Position;
@property(atomic,assign) GLKVector3 light1SpotDirection;
@property(atomic,assign) GLKVector4 light2Position;

@property(nonatomic,assign) GLKMatrix4 textureMatrix2d0;
@property(nonatomic,assign) GLKMatrix4 textureMatrix2d1;

-(void)prepareToDrawMultitextures;

@end

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;

@end


