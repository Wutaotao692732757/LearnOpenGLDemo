//
//  ViewController.m
//  GLDemo1
//
//  Created by wutaotao on 2017/4/13.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property(nonatomic,strong) EAGLContext *mContext;
@property(nonatomic,strong) GLKBaseEffect *mEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfig];
    [self uploadVertexArray];
    [self uploadTexture];
    
}

-(void)setupConfig {
    
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.mContext];
    
}

-(void)uploadVertexArray{
    GLfloat squareVertexData[] = {
        
        0.5, -0.5, 0.0f,  1.0f, 0.0f,
        0.5, 0.5, -0.0f,  1.0f, 1.0f,
        -0.5, 0.5, 0.0f,  0.0f, 1.0f,
        
        0.5, -0.5, 0.0f,  1.0f, 0.0f,
        -0.5, 0.5, 0.0f,  0.0f, 1.0f,
        -0.5, -0.5, 0.0f, 0.0f, 0.0f,
        
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);//ding dain shu ju huan cun
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}



-(void)uploadTexture{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    self.mEffect = [[GLKBaseEffect alloc]init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
    
    
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 1.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}


@end
