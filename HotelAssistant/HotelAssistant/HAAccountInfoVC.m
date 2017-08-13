//
//  HAAccountInfoVC.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/13.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAAccountInfoVC.h"
#import "HAAccountTableViewCell.h"

@interface HAAccountInfoVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@end

@implementation HAAccountInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"账户资料";
    self.mytableview.delegate=self;
    self.mytableview.dataSource=self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        return 20;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAAccountTableViewCell *cell = [HAAccountTableViewCell accountCellWithtableView:tableView];
    cell.myindex=indexPath;
    
    return cell;
}

@end
