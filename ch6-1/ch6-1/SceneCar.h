//
//  SceneCar.h
//  ch6-1
//
//  Created by wutaotao on 2017/5/23.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "SceneModel.h"

@protocol SceneCarControllerProtocol

-(NSTimeInterval)timeSincelastUpdate;
- (SceneAxisAllignedBoundingBox)rinkBoundingBox;
-(NSArray *)cars;

@end

@interface SceneCar : NSObject

@property (strong,nonatomic,readonly) SceneModel *model;
@property (assign,nonatomic,readonly) GLKVector3 position;
@property (assign,nonatomic,readonly) GLKVector3 nextPosition;
@property (assign,nonatomic,readonly) GLKVector3 velocity;
@property (assign,nonatomic,readonly) GLfloat yawRadians;
@property (assign,nonatomic,readonly) GLfloat targetYawRadians;
@property (assign,nonatomic,readonly) GLKVector4 color;
@property (assign,nonatomic,readonly) GLfloat radius;

-(id)initWithModel:(SceneModel *)aModel position:(GLKVector3)aPosition
          velocity:(GLKVector3)aVelocity color:(GLKVector4)aColor;

-(void)updateWithController:(id<SceneCarControllerProtocol>)controller;

-(void)drawWithBaseEffect:(GLKBaseEffect *)anEffect;

@end

extern GLfloat SceneScalarFastLowpassFilter(NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                            GLfloat current);

extern GLfloat SceneScalarSlowLowPassFilter(NSTimeInterval timeSinceLastUpdate,
                                            GLfloat target,
                                            GLfloat current);
extern GLKVector3 SceneVector3FastLowPassFilter(NSTimeInterval timeSinceLastUpdate, GLKVector3 target, GLKVector3 current);

extern GLKVector3 SceneVector3SlowLowPassFilter(NSTimeInterval timeSinceLastUpdate, GLKVector3 target, GLKVector3 current);











