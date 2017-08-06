//
//  HAChangeCardVC.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAChangeCardVC.h"

@interface HAChangeCardVC ()

@end

@implementation HAChangeCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.nameTitle;
    if ([_nameTitle isEqualToString:@"添加银行卡"]) {
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    }
    
    
    
    
}


@end
