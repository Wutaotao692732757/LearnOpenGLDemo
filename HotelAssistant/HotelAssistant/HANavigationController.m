//
//  HANavigationController.m
//  HotelAssistant
//
//  Created by apple on 2017/7/4.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HANavigationController.h"

@interface HANavigationController ()

@end

@implementation HANavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   // @"返回icon@3x"
    
//    self.navigationBar.backgroundColor = [UIColor blackColor];
    self.navigationBar.titleTextAttributes =@{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationBar.barTintColor = [UIColor blackColor];
//    self.navigationBar.tintColor=[UIColor whiteColor];
   
    UIImage *backimg = [UIImage imageNamed:@"返回icon"];
    
    backimg = [backimg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.navigationBar.backIndicatorImage = backimg;
    
    self.navigationBar.backIndicatorTransitionMaskImage = backimg;
 
    
    UIBarButtonItem *buttonItem = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    
    UIOffset offset;
    
    offset.horizontal = -500;
    
    [buttonItem setBackButtonTitlePositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
    
        
    
}



@end
