//
//  ViewController.m
//  ch3-4
//
//  Created by wutaotao on 2017/4/28.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"

//定义顶点结构体
typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

static const SceneVertex vertices[] = {
    {{-1.0f,-0.67f,0.0f}, {0.0f,0.0f}},
    {{1.0f,0.67f,0.0f},{1.0f,1.0f}},
    {{-1.0f,0.67f,0.0f},{0.0f,1.0f}},
    
    {{1.0f,-0.67,0.0f},{1.0f,0.0f}},
    {{1.0f,0.67f,0.0f},{1.0f,1.0f}},
    {{-1.0f,-0.67f,0.0f},{0.0f,0.0f}}
};

@interface ViewController ()
//基本着色器
@property(nonatomic,strong)GLKBaseEffect *baseEffect;
//定点缓存
@property(nonatomic,assign)GLuint vertexBuffer;
//纹理1
@property(nonatomic,strong)GLKTextureInfo* textureInfo0;
//纹理2
@property(nonatomic,strong)GLKTextureInfo* textureInfo1;

@end
 GLuint name;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
   
    glGenBuffers(1, &name);
    
    glBindBuffer(GL_ARRAY_BUFFER, name);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // setup texture0
    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    
    self.textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:nil];
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                [NSNumber numberWithBool:YES],
                                                                                GLKTextureLoaderOriginBottomLeft, nil] error:nil];
    glEnable(GL_BLEND);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 6, GL_FLOAT, GL_FALSE, sizeof(vertices), NULL + offsetof(SceneVertex, positionCoords));
    
 
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 6, GL_FLOAT, GL_FALSE, sizeof(vertices), NULL + offsetof(SceneVertex, textureCoords));

    self.baseEffect.texture2d0.name = self.textureInfo0.name;
    self.baseEffect.texture2d0.target = self.textureInfo0.target;
    [self.baseEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
//    self.baseEffect.texture2d0.name = self.textureInfo1.name;
//    self.baseEffect.texture2d0.target = self.textureInfo1.target;
//    [self.baseEffect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLES, 0, 6);
    
}




@end



























