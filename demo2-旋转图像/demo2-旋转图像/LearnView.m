//
//  LearnView.m
//  demo2-旋转图像
//
//  Created by wutaotao on 2017/4/15.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "LearnView.h"
#import <OpenGLES/ES2/gl.h>

@interface LearnView ()

@property (nonatomic,strong) EAGLContext *myContext; // 绘图上下文
@property (nonatomic,strong) CAEAGLLayer *myEagLayer; // 绘制的图层
@property (nonatomic,assign) GLuint myProgram;  // 着色器程序


@property (nonatomic,assign) GLuint myColorRenderBuffer; // 顶点着色器
@property (nonatomic,assign) GLuint myColorFrameBuffer; // 片段着色器

-(void)setupLayer;

@end


@implementation LearnView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)layoutSubviews{
    
    [self setupLayer];
    [self setupContext];
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
}



-(void)render{
    
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    //加载着色器
    self.myProgram = [self loadShaders:vertFile frag:fragFile];
    
    //链接
    glLinkProgram(self.myProgram);
    GLint linkSuccess;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
    
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error:%@",messageString);
        return ;
        
    } else {
        NSLog(@"link ok");
        
        glUseProgram(self.myProgram);
    }
    
    GLfloat attrArr[] = {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
   
    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL +3);
    glEnableVertexAttribArray(textCoor);
    
    [self setuptexture:@"for_test.jpg"];
    
    
    GLuint rotate = glGetUniformLocation(self.myProgram, "rotateMatrix");
    float radians = 10 * 3.14159f / 180.0f;
    float s = sin(radians);
    float c = cos(radians);
    
    GLfloat zRotation[16] = {
        c, -s, 0, 0.2, //
        s, c, 0, 0,//
        0, 0, 1.0, 0,//
        0.0, 0, 0, 1.0//
    
    };
    
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}



-(GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag{
    
    GLuint verShader , fragShader;
    GLint program = glCreateProgram();
    
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    //读取字符串
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
}

-(void)setupLayer{
    
    self.myEagLayer = (CAEAGLLayer *) self.layer;
    
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.myEagLayer.opaque = YES;
    
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
    
}

-(void)setupContext {
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    
    if (!context) {
        NSLog(@"initialize fail");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set context");
        exit(1);
    }
    self.myContext = context;
    
}

// 创建片段着色器
-(void)setupRenderBuffer{
    
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer=buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
    
}

// 创建顶点着色器
-(void)setupFrameBuffer{
    
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

//销毁两个着色器
-(void)destoryRenderAndFrameBuffer{
    
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
}

-(GLuint)setuptexture:(NSString *)fileName{
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    
    if (!spriteImage) {
        NSLog(@"failed to load Image %@",fileName);
    }
    
    // 2 读取图片大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width , fh = height;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(spriteData);
    
    return 0;
}

@end

























