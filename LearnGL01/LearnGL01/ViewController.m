//
//  ViewController.m
//  LearnGL01
//
//  Created by wutaotao on 2017/4/24.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic,strong)EAGLContext *mcontext;

//基本着色器程序
@property(nonatomic,strong)GLKBaseEffect *mEffect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfig];
    [self uploadVertexArrary];
    [self uploadTexture];
    // Do any additional setup after loading the view, typically from a nib.
}

// 初始化环境
-(void)setupConfig{
    
    self.mcontext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    
    view.context = self.mcontext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.mcontext];

}
//初始化,绑定缓存 开启缓存数据, 设置访问的值得指针
-(void)uploadVertexArrary{
    GLfloat squareVertexData[] = {
        
      0.5f,  0.0f, 0.0f,
      -0.5f, 0.0f, 0.0f,
      0.0f,  0.5f, 0.0f,
    };
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, 0);
}

//初始化着色器
-(void)uploadTexture{
    
    self.mEffect = [[GLKBaseEffect alloc]init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    
    
}

//重写重绘
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.1f, 0.3f, 0.2f, 1);
    glClear(GL_COLOR_BUFFER_BIT);
   
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_LINE_LOOP, 0, 3);
}



@end
