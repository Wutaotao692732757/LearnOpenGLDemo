//
//  SoundEffect.h
//  绘图
//
//  Created by wutaotao on 2017/4/19.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@interface SoundEffect : NSObject{
    SystemSoundID _soundID;
}

+ (id) soundEffectWithContentsOfFile:(NSString *)aPath;
- (id) initWithContentsOfFile:(NSString *)path;
- (void)play;

@end
