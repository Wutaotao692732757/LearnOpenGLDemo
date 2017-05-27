//
//  ModelData.m
//  AEE
//
//  Created by aee on 16/6/1.
//  Copyright (c) 2016年 LIU. All rights reserved.
//

#import "ModelData.h"

@implementation ModelData
static id mode = nil;
- (void)cameraCurrentStatuModel{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSNumber *type = [user objectForKey:@"photoType"];
    if (!type) {
        [user setObject:@0 forKey:@"photoType"];
        [user synchronize];
    }
}

+ (instancetype)shareData{
    if (!mode) {
        @synchronized(self){
            
            if (!mode) {
                mode = [[self alloc]init];
            }
            return mode;
        }
        
    }
    return mode;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!mode) {
        
        @synchronized(self){
            if (!mode) {
                mode = [super allocWithZone:zone];
            }
        }
    }
    return mode;
}

- (id)init{
    self = [super init];
    if (self) {
        //
    }
    return self;
}
@end
