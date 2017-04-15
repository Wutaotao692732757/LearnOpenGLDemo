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
        
        0.8, -0.5, 0.0f,  1.0f, 0.0f,
        0.5, 0.5, -0.0f,  1.0f, 1.0f,
        -0.8, 0.5, 0.0f,  0.0f, 1.0f,
        
        0.8, -0.5, 0.0f,  1.0f, 0.0f,
        -0.8, 0.5, 0.0f,  0.0f, 1.0f,
        -0.5, -0.5, 0.0f, 0.0f, 0.0f,
        
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer); // 创建顶点缓存对象
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);  // 顶点数据复制到缓存的内存中
    // GL_STATIC_DRAW  数据几乎不会改变
    // GL_DYNAMIC_DRAW  数据会被改变很多
    // GL_STREAM_DRAW  数据每次绘制时都会改变
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);//ding dain shu ju huan cun
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    
    
    
}



-(void)uploadTexture{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
//    self.mEffect = [[GLKBaseEffect alloc]init];
//    self.mEffect.texture2d0.enabled = GL_TRUE;
//    self.mEffect.texture2d0.name = textureInfo.name;
    
    
    //    glCreateShader(GL_VERTEX_SHADER);
    
}

-(GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag{
    
    GLuint verShader, fragShader;
    
    //着色器程序
    GLuint program = glCreateProgram();
    //1.compile
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];//顶点着色器
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];//片段着色器
    //2.attach
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    //3. 释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    return program;
}

-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar * source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}




- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.1f, 0.9f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}


@end
