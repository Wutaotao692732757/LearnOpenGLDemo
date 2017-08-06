//
//  HAPersonGetMonkeyVC.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAPersonGetMonkeyVC.h"
#import "HAChangeCardVC.h"

@interface HAPersonGetMonkeyVC ()

@end

@implementation HAPersonGetMonkeyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"提现";
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)addBtnDidClicked:(id)sender {
    
    HAChangeCardVC *changeVC = [[HAChangeCardVC alloc]init];
    
    changeVC.nameTitle = @"添加银行卡";
    [self.navigationController pushViewController:changeVC animated:YES];
    
    
    
}
 

@end
