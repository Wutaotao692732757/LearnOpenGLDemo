//
//  weakTimer.h
//  EX_appIOS
//
//  Created by mac_w on 2016/12/14.
//  Copyright © 2016年 aee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface weakTimer : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer* timer;

+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      target:(id)aTarget
                                    selector:(SEL)aSelector
                                    userInfo:(id)userInfo
                                     repeats:(BOOL)repeats;
@end
