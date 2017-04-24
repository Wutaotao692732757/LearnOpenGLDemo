//
//  ViewController.m
//  ch2-1
//
//  Created by wutaotao on 2017/4/24.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    GLuint vertextBufferID;
}
//基本类型着色器
@property (nonatomic,strong) GLKBaseEffect *baseEffect;

@end
//存储每个顶点信息
typedef struct {
    GLKVector3 positionCoords;
} SceneVertex;


@implementation ViewController

//定义顶点坐标
  SceneVertex vertices[] = {
    -0.5f, 0.0f, 0.0f,
    0.5f, 0.0f, 0.0f,
    0.0f, 0.5f, 0.0f,
};

static const SceneVertex vertices2[] =
{
    {{-0.5f,  0.5f, 0.0}},  // upper left corner
    {{-0.5f, -0.5f, 0.0}}, // lower left corner
    {{ 0.5f, -0.5f, 0.0}} // lower right corner
};


- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
   
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];

    self.baseEffect=[[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor=GL_TRUE;// 内部一样颜色
    self.baseEffect.constantColor=GLKVector4Make(0.2f, 0.1f, 0.6f, 1.0f);
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    
    glGenBuffers(1, &vertextBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertextBufferID);
    
    //申请空间
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

}

NSInteger count = 0;

//绘制
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    count++;
    
    
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    //启用顶点值
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    if (count%2==0) {
        //拷贝空间
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices2), vertices2, GL_STATIC_DRAW);
        
    }else{
        //拷贝空间
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        
    }
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    
    glDrawArrays(GL_LINE_LOOP, 0, 3);
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (0 != vertextBufferID) {
        glDeleteBuffers(1, &vertextBufferID);
        vertextBufferID = 0;
    }
    
    
    view.context = nil;
    [EAGLContext setCurrentContext:nil];
    
}

@end























