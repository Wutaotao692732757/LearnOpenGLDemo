//
//  ViewController.m
//  ch4-2
//
//  Created by wutaotao on 2017/5/4.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

typedef struct {
    GLKVector3 position;
    GLKVector2 textureCoords;
}SceneVertex;

typedef struct {
    SceneVertex vertices[3];
}SceneTriangle;

static SceneVertex vertexA = {{-0.5,0.5,-0.5},{0.0,1.0}};
static SceneVertex vertexB = {{-0.5,0.0,-0.5},{0.0,0.5}};
static SceneVertex vertexC = {{-0.5,-0.5,-0.5},{0.0,0.0}};
static SceneVertex vertexD = {{0.0,0.5,-0.5},{0.5,1.0}};
static SceneVertex vertexE = {{0.0,0.0,0.0},{0.5,0.5}};
static SceneVertex vertexF = {{0.0,-0.5,-0.5},{0.5,0.0}};
static SceneVertex vertexG = {{0.5,0.5,-0.5},{1.0,1.0}};
static SceneVertex vertexH = {{0.5,0.0,-0.5},{1.0,0.5}};
static SceneVertex vertexI = {{0.5,-0.5,-0.5},{1.0,0.0}};

static SceneTriangle SceneTriangleMake(
const SceneVertex vertexA,
const SceneVertex vertexB,
const SceneVertex vertexC
);


@interface ViewController (){
    SceneTriangle triangles[8];
}

@property(nonatomic,strong)GLKBaseEffect *baseEffect;
@property(nonatomic,strong)AGLKVertexAttribArrayBuffer *vertexBuffer;
@property(nonatomic,strong)GLKTextureInfo *blandTextureInfo;
@property(nonatomic,strong)GLKTextureInfo *interestingTextureInfo;
@property(nonatomic,assign)BOOL shouldUseDetailLighting;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"view isnot a GLKView");
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    {
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 0.25f);
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    
    CGImageRef blandSimulatedLightingImageRef = [[UIImage imageNamed:@"Lighting256x256.png"] CGImage];
    _blandTextureInfo = [GLKTextureLoader textureWithCGImage:blandSimulatedLightingImageRef options:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil]  error:NULL];
    CGImageRef interestingSimulatedLightingImageRef = [[UIImage imageNamed:@"LightingDetail256x256.png"] CGImage];
    _interestingTextureInfo = [GLKTextureLoader textureWithCGImage:interestingSimulatedLightingImageRef options:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES],
        GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
    
    self.shouldUseDetailLighting =YES;
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    self.baseEffect.texture2d0.name=_interestingTextureInfo.name;
    self.baseEffect.texture2d0.target=_interestingTextureInfo.target;
    [self.baseEffect prepareToDraw];
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles)/sizeof(SceneVertex)];
    
    
    
    
}


static SceneTriangle SceneTriangleMake(
   const SceneVertex vertexA,
   const SceneVertex vertexB,
   const SceneVertex vertexC
){
    SceneTriangle result;
    
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    return result;
}

@end















