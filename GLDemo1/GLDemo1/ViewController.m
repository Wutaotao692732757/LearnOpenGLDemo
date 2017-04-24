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
        
         0.8, 0.0,  0.0f,
        -0.9, 0.0,  0.0f,
         0.0, 0.5,  0.0f,
 
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer); // 创建顶点缓存对象
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);  // 顶点数据复制到缓存的内存中
    // GL_STATIC_DRAW  数据几乎不会改变
    // GL_DYNAMIC_DRAW  数据会被改变很多
    // GL_STREAM_DRAW  数据每次绘制时都会改变
    // 开启渲染使用缓存数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);//ding dain shu ju huan cun
 // 需要访问缓存数据的类型和所有需要访问的数据的内存偏移值
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, (GLfloat *)NULL + 0);
   

}



-(void)uploadTexture{
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
//    
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //
    //初始化一个默认的GPU 着色器程序
    self.mEffect = [[GLKBaseEffect alloc]init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
//    self.mEffect.texture2d0.name = textureInfo.name;
    
    
//    glCreateShader(GL_VERTEX_SHADER);
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.1f, 0.2f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_LINE_LOOP, 0, 3);
}


@end
