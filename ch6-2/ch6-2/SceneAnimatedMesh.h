//
//  SceneAnimatedMesh.h
//  ch6-2
//
//  Created by wutaotao on 2017/6/24.
//  Copyright © 2017年 wutaotao. All rights reserved.
//
#import "SceneMesh.h"


@interface SceneAnimatedMesh : SceneMesh

- (void)drawEntireMesh;
- (void)updateMeshWithDefaultPositions;
- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval;

@end
