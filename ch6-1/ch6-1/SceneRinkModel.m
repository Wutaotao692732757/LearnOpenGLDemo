//
//  SceneRinkModel.m
//  ch6-1
//
//  Created by wutaotao on 2017/5/23.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "SceneRinkModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperRink.h"

@implementation SceneRinkModel

-(id)init
{
    SceneMesh *rinkMesh = [[SceneMesh alloc]initWithPositionCoords:bumperRinkVerts normalCoords:bumperRinkNormals texCoords0:NULL numberOfPositions:bumperRinkNumVerts indices:NULL numberOfIndices:0];
    
    if (nil != (self = [super initWithName:@"bumberRink" mesh:rinkMesh numberOfVertices:bumperRinkNumVerts])) {
        
        [self updateAlignedBoundingBoxForVertices:bumperRinkVerts count:bumperRinkNumVerts];
    }
    return self;
}



@end
