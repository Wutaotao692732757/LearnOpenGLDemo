//
//  ViewController.m
//  3ch-3
//
//  Created by wutaotao on 2017/4/26.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"

//定义顶点结构体
typedef struct{
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

//定义顶点数据和纹理坐标
static SceneVertex vertices[] = {
    {{-0.5f,-0.5f,0.0f},{0.0f,0.0f}}, //左
    {{0.5f,-0.5f,0.0f},{1.0f,0.0f}},  // 右
    {{-0.5f,0.5f,0.0f},{0.0f,1.0f}}   // 上
};

// 每次移动的距离
static GLKVector3 movementVectors[3] = {
    {-0.02f, -0.01f, 0.0f},
    {0.01f,  -0.005f,0.0f},
    {-0.01f,  0.01f,0.0f},
};


@interface ViewController ()

//基本着色器程序
@property(nonatomic,strong)GLKBaseEffect *baseEffect;
@end
GLuint name;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化上下文
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // 设置为当前上下文
    [EAGLContext setCurrentContext:view.context];
    
    //初始化着色器程序
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    //初始化内部颜色为白色
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    glClearColor(
                 0.0f,
                 0.0f,
                 0.0f,
                 0.0f);
    //1.定义顶点缓存名字
    
    glGenBuffers(1, &name);
    //2.绑定当前缓存
    glBindBuffer(GL_ARRAY_BUFFER, name);
    //3.拷贝到GPU内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(SceneVertex)*3, vertices, GL_DYNAMIC_DRAW);
    
    //加载图片
    CGImageRef imageRef = [[UIImage imageNamed:@"grid.png"] CGImage];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:nil];
    
    self.baseEffect.texture2d0.name=textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
    glBindTexture(self.baseEffect.texture2d0.target, self.baseEffect.texture2d0.name);
//    glTexParameteri(
//                    self.baseEffect.texture2d0.target,
//                    GL_TEXTURE_WRAP_S,
//                    GL_CLAMP_TO_EDGE);
    glTexParameteri(
                    self.baseEffect.texture2d0.target,
                    GL_TEXTURE_MAG_FILTER,
                    GL_NEAREST);
//
//    glBindTexture(self.target, self.name);
//    
//    glTexParameteri(
//                    self.target,
//                    parameterID,
//                    value);
    
    
    
    
}

-(void)update{
    NSLog(@"更新");
    [self updateAnimationVertexPositons];
    
    
    //2.绑定当前缓存
    glBindBuffer(GL_ARRAY_BUFFER, name);
    //3.拷贝到GPU内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(SceneVertex)*3, vertices, GL_DYNAMIC_DRAW);
    
    
}

//更新顶点数据的方法
-(void)updateAnimationVertexPositons{
    
    for (int i = 0; i < 3; i++) {
        
        vertices[i].positionCoords.x += movementVectors[i].x;
        
        if (vertices[i].positionCoords.x >= 1.0f || vertices[i].positionCoords.x<=-1.0f) {
            movementVectors[i].x = -movementVectors[i].x;
        }
        
        vertices[i].positionCoords.y += movementVectors[i].y;
        
        if (vertices[i].positionCoords.y >= 1.0f || vertices[i].positionCoords.y<=-1.0f) {
            movementVectors[i].y = -movementVectors[i].y;
        }
        
        vertices[i].positionCoords.z += movementVectors[i].z;
        
        if (vertices[i].positionCoords.z >= 1.0f || vertices[i].positionCoords.z<=-1.0f) {
            movementVectors[i].z = -movementVectors[i].z;
        }
        
    }
    
    
    
    
}



-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //4. 开启顶点着色器
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    //5. 设置着色器的顶点
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex),NULL + offsetof(SceneVertex, positionCoords));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT,  GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoords));
    [self.baseEffect prepareToDraw];
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   //6. 绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    
}


@end
