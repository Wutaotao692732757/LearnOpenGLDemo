//
//  ViewController.m
//  imageTEst
//
//  Created by wutaotao on 2017/7/17.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageTest;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _imageTest.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://pic1.zhimg.com/v2-9dfc90b3d52af1fbfc7acb6dc62ebcac.png"]]];
    
    
    
}




@end
