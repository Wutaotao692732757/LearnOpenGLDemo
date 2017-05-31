//
//  SceneModel.h
//  ch6-4
//
//  Created by wutaotao on 2017/5/31.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "SceneMesh.h"
typedef struct
{
    GLKVector3 min;
    GLKVector3 max;
}
SceneAxisAllignedBoundingBox;

@interface SceneModel : NSObject

@property (copy, nonatomic, readonly) NSString
*name;
@property (assign, nonatomic, readonly)
SceneAxisAllignedBoundingBox axisAlignedBoundingBox;


- (id)initWithName:(NSString *)aName
              mesh:(SceneMesh *)aMesh
  numberOfVertices:(GLsizei)aCount;

- (void)draw;

- (void)updateAlignedBoundingBoxForVertices:(float *)verts
                                      count:(unsigned int)aCount;

@end
