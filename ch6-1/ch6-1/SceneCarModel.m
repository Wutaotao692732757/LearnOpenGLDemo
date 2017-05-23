//
//  SceneCarModel.m
//  ch6-1
//
//  Created by wutaotao on 2017/5/23.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "SceneCarModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperCar.h"

@implementation SceneCarModel


- (id)init{
    
    SceneMesh *carMesh = [[SceneMesh alloc]initWithPositionCoords:bumperCarVerts normalCoords:bumperCarNormals texCoords0:NULL numberOfPositions:bumperCarVerts indices:NULL numberOfIndices:0];
    
    if (nil != (self = [super initWithName:@"bumberCar" mesh:carMesh numberOfVertices:bumperCarNumVerts])) {
        [self updateAlignedBoundingBoxForVertices:bumperCarVerts count:bumperCarNumVerts];
    }
    
    return self;
}




@end
