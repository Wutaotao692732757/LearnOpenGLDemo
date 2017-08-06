//
//  HotelLoginInVC.m
//  HotelAssistant
//
//  Created by 伍陶陶 on 2017/7/19.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HotelLoginInVC.h"
#import "HAHotelRegistVC.h"
#import "HAFindPassWordVC.h"
#import "HARegistViewController.h"

@interface HotelLoginInVC ()

@property (weak, nonatomic) IBOutlet UIImageView *loginBannerImg;



@end

@implementation HotelLoginInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isHotel==YES) {
        _loginBannerImg.image = [UIImage imageNamed:@"酒店登录banner"];
        
        self.navigationItem.title=@"酒店登录";
    }else{
        
        _loginBannerImg.image=[UIImage imageNamed:@"客户登录banner"];
        
          self.navigationItem.title=@"个人登录";
    }
    
    
    
    
}

- (IBAction)loginBtnDidClicked:(id)sender {
    // 登录操作
    
    
}




- (IBAction)registBtnDidClicked:(id)sender {
    
    if (_isHotel==YES) {
        
        HAHotelRegistVC *registVC = [[HAHotelRegistVC alloc] init];
        
        [self.navigationController pushViewController:registVC animated:YES];
        
    }else{
        HARegistViewController *personregistVC = [[HARegistViewController alloc]init];
        
        [self.navigationController pushViewController:personregistVC animated:YES];
        
    }
    
    
    
}

- (IBAction)forgeterBtnDidClicked:(id)sender {
    
    HAFindPassWordVC * findPasswordVC = [[HAFindPassWordVC alloc]init];
    findPasswordVC.isHotel = self.isHotel;
    [self.navigationController pushViewController:findPasswordVC animated:YES];
}


- (IBAction)thirdLoginBtnDidClicked:(id)sender {
    
    // 微信登录
    
}




@end
