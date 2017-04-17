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

@end

@implementation ViewController
   GLuint shaderProgram;
  GLuint VBO;
GLfloat vertices[] = {
    -0.5, -0.5, 0.0f,
    0.5f, -0.5f, 0.0f,
    0.0f, 0.5f, 0.0f
};
- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.mContext];
    
 
    [self creatShader];
    
}



-(void)creatShader{
    
    //初始化顶点坐标
  
    // 创建顶点缓存对象
  
    glGenBuffers(1, &VBO);
    //绑定缓存
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    //配置当前绑定的缓存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    //创建顶点着色器
    GLuint vertexShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);
    
    //读取文件路径
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    
    NSString* Vcontent = [NSString stringWithContentsOfFile:vertFile encoding:NSUTF8StringEncoding error:nil];
    const GLchar* vertextsource = (GLchar *)[Vcontent UTF8String];
    
    
    glShaderSource(vertexShader, 1, &vertextsource, NULL);
    glCompileShader(vertexShader);
    
    //片段着色器路径
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    NSString* Fcontent = [NSString stringWithContentsOfFile:fragFile encoding:NSUTF8StringEncoding error:nil];
    const GLchar* fragmentsource = (GLchar *)[Fcontent UTF8String];
    
    
    // 片段着色器
    GLuint fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentsource, NULL);
    glCompileShader(fragmentShader);
    
    //着色器程序
 
    shaderProgram = glCreateProgram();
    
    //用着色器添加到程序对象上
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    //激活这个程序
    glUseProgram(shaderProgram);
    
    //删除着色器对象
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), (GLvoid*)0);
        glEnableVertexAttribArray(0);
    
    //复制顶点数组到缓冲中供OpenGL使用
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    //设置顶点属性指针
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    //当我们渲染一个物体时要使用着色器程序
    glUseProgram(shaderProgram);
}



-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    
    
    
//    glClearColor(0.1f, 0.3f, 0.1f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
      // 怎么绘制呢?和windows 平台不一样...
    
 
    
    
}






@end
