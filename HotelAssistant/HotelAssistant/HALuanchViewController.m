//
//  HALuanchViewController.m
//  HotelAssistant
//
//  Created by 伍陶陶 on 2017/7/17.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HALuanchViewController.h"
#import "HotelLoginInVC.h"
#import "HAHotelRegistVC.h"
#import "HARegistViewController.h"



@interface HALuanchViewController ()

@property (weak, nonatomic) IBOutlet UIButton *hotelRegistBtn;

@property (weak, nonatomic) IBOutlet UIButton *personRegistBtn;

@end

@implementation HALuanchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hotelRegistBtn.layer.cornerRadius=20;
    _hotelRegistBtn.layer.masksToBounds=YES;
    _hotelRegistBtn.layer.borderColor=[UIColor whiteColor].CGColor;
    _hotelRegistBtn.layer.borderWidth=1.0;
    
    _personRegistBtn.layer.cornerRadius=20;
    _personRegistBtn.layer.masksToBounds=YES;
    _personRegistBtn.layer.borderColor=[UIColor whiteColor].CGColor;
    _personRegistBtn.layer.borderWidth=1.0;
    
  
}


- (IBAction)personLogin:(id)sender {
    
    
    HotelLoginInVC *hotelLoginVC =  [[HotelLoginInVC alloc] init];
    hotelLoginVC.isHotel=NO;
    
    
    [self.navigationController pushViewController:hotelLoginVC animated:YES];
    
    
}


- (IBAction)personRegisterBtnDidClicked:(id)sender {
    
    HARegistViewController *personregistVC = [[HARegistViewController alloc]init];
    
    [self.navigationController pushViewController:personregistVC animated:YES];
    
    
}


- (IBAction)hotelRegistBtnDidClicked:(id)sender {
    
    HAHotelRegistVC *hotelRegistVC = [[HAHotelRegistVC alloc]init];
    
    [self.navigationController pushViewController:hotelRegistVC animated:YES];
    
    
}

- (IBAction)hotelLoginBtnDidClicked:(id)sender {
    
    HotelLoginInVC *hotelLoginVC =  [[HotelLoginInVC alloc] init];
    hotelLoginVC.isHotel=YES;
    
    
    [self.navigationController pushViewController:hotelLoginVC animated:YES];
    
    
    
    
    
    
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    self.navigationController.navigationBar.hidden=NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
}



@end














