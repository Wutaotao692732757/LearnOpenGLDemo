//
//  ViewController.m
//  ch5-1
//
//  Created by wutaotao on 2017/5/5.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "sphere.h"

@interface ViewController ()

@property(nonatomic,strong) GLKBaseEffect *baseEffrct;
@property(nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property(nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property(nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"view controller's view is not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffrct = [[GLKBaseEffect alloc] init];
    self.baseEffrct.light0.enabled = GL_TRUE;
    self.baseEffrct.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    self.baseEffrct.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    self.baseEffrct.light0.position = GLKVector4Make(1.0f, 0.0f, -0.8f, 0.0f);
    
    CGImageRef imageRef = [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:[NSDictionary dictionaryWithObjectsAndKeys:                              [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    self.baseEffrct.texture2d0.name = textureInfo.name;
    self.baseEffrct.texture2d0.target = textureInfo.target;
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(3*sizeof(GLfloat)) numberOfVertices:sizeof(sphereVerts)/(3 * sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereNormals)/(3*sizeof(GLfloat)) bytes:sphereNormals usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(2*sizeof(GLfloat)) numberOfVertices:sizeof(sphereTexCoords)/(2*sizeof(GLfloat)) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffrct prepareToDraw];
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    
}


@end













