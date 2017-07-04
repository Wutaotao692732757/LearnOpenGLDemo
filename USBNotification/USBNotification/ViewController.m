//
//  ViewController.m
//  USBNotification
//
//  Created by wutaotao on 2017/7/4.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(somechangemath) name:UIDeviceBatteryStateDidChangeNotification object:nil];
}


-(void)somechangemath{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.backgroundColor=[UIColor redColor];
    });
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
  
    
    
    
}





@end
