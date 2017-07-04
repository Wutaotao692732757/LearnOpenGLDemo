//
//  AppDelegate.m
//  usbNotifacation
//
//  Created by wutaotao on 2017/7/4.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "AppDelegate.h"
#import "PTUSBHub.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserverForName:@"PTUSBDeviceDidAttachNotification" object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        NSLog(@"USB连接上了了了,,");
        
        
    }];

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
