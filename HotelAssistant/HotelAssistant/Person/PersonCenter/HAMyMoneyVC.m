//
//  HAMyMoneyVC.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//
#import "HAPersonGetMonkeyVC.h"
#import "HAMyMoneyVC.h"

@interface HAMyMoneyVC ()
@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@end

@implementation HAMyMoneyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"钱包";
    
    
    
    
    
    
    
}

- (IBAction)getBackMoneybtnDidClicked:(id)sender {
    
    
    HAPersonGetMonkeyVC *getbackMoneyVC = [[HAPersonGetMonkeyVC alloc]init];
    
    
    [self.navigationController pushViewController:getbackMoneyVC animated:YES];
    
    
    
    
    
    
    
}


@end
