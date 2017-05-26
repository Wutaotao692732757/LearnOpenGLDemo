//
//  ViewController.h
//  ch6-1
//
//  Created by wutaotao on 2017/5/20.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "SceneCar.h"

@interface ViewController : GLKViewController<SceneCarControllerProtocol>

@property (readonly, nonatomic, strong) NSArray *cars;

@property (readonly, nonatomic, assign) SceneAxisAllignedBoundingBox rinkBoundingBox;
@end

