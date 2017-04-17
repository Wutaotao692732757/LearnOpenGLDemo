//
//  ViewController.m
//  demo2-旋转图像
//
//  Created by wutaotao on 2017/4/15.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import "LearnView.h"

@interface ViewController ()
@property (nonatomic,strong) LearnView *myView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = (LearnView *)self.view;
     
}





@end
