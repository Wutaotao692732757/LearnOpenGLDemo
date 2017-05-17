//
//  ViewController.h
//  ch5-4
//
//  Created by wutaotao on 2017/5/17.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"

typedef enum {
    
    SceneTranslate = 0,
    SceneRotate,
    SceneScale,

} SceneTransformationSelector;

typedef enum {

    SceneXAxis = 0,
    SceneYAxis,
    SceneZAxis,
    
} SceneTransformationAxisSelector;



@interface ViewController : GLKViewController
{
    SceneTransformationSelector transform1Type;
    SceneTransformationAxisSelector transform1Axis;
    float                           transform1Value;
    SceneTransformationSelector     transform2Type;
    SceneTransformationAxisSelector transform2Axis;
    float                           transform2Value;
    SceneTransformationSelector     transform3Type;
    SceneTransformationAxisSelector transform3Axis;
    float                           transform3Value;
    
}

@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexNormalbuffer;





@end













