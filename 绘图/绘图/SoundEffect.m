//
//  SoundEffect.m
//  绘图
//
//  Created by wutaotao on 2017/4/19.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "SoundEffect.h"

@implementation SoundEffect
+ (id) soundEffectWithContentsOfFile:(NSString *)aPath{
    
    if (aPath) {
        return [[SoundEffect alloc]initWithContentsOfFile:aPath];
    }
    
    return nil;
}
- (id) initWithContentsOfFile:(NSString *)path{
    self = [super init];
    
    if (self != nil) {
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        
        if (aFileURL != nil) {
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL,&aSoundID);
            
            if (error == kAudioServicesNoError) {
                _soundID = aSoundID;
            } else {
                NSLog(@"error");
            }
    
        }else{
            NSLog(@"NSURL is nil for path : %@",path);
            self = nil;
        }
 
    }
 
    return self;
}
- (void)play{
    AudioServicesPlaySystemSound(_soundID);
}

-(void)dealloc{
    AudioServicesDisposeSystemSoundID(_soundID);
}

@end














