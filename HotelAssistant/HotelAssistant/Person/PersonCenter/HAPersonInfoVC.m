//
//  HAPersonInfoVC.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAPersonInfoVC.h"
#import "HAinfoCell.h"
#define  SCREENW  [UIScreen mainScreen].bounds.size.width
#define  SCREENH  [UIScreen mainScreen].bounds.size.height
@interface HAPersonInfoVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *infoTableView;

@end

@implementation HAPersonInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.title=@"个人信息";
    
    [self.view addSubview:self.infoTableView];
    
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    self.infoTableView.separatorStyle=UITableViewCellSeparatorStyleNone;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAinfoCell *cell = [HAinfoCell HAinfoCellWithTableView:tableView];
    cell.infoCellPath = indexPath;
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}



//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    return nil;
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return nil;
//}

-(UITableView *)infoTableView
{
    if (_infoTableView==nil) {
        _infoTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 74, SCREENW, 250) style:UITableViewStylePlain];
    }
    return _infoTableView;
}




@end
