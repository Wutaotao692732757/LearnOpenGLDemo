//
//  HAHotelRegistVC.m
//  HotelAssistant
//
//  Created by 伍陶陶 on 2017/7/29.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAHotelRegistVC.h"

@interface HAHotelRegistVC ()

@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;


@end

@implementation HAHotelRegistVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"酒店注册";
    _uploadBtn.layer.borderWidth=1.0;
    _uploadBtn.layer.borderColor= [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
    
    
    
    
    
}

 


@end
