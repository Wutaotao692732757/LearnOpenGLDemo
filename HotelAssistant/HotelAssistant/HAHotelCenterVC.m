//
//  HAHotelCenterVC.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/13.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAHotelCenterVC.h"
#import "HAHotelCenterTableViewCell.h"
#import "HAAccountInfoVC.h"
@interface HAHotelCenterVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;


@end

@implementation HAHotelCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    self.myTableView.scrollEnabled=NO;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAHotelCenterTableViewCell *cell = [HAHotelCenterTableViewCell hotelCenterCellInitWithTableView:tableView];
    
    cell.myindex=indexPath;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        HAAccountInfoVC *infoVC = [[HAAccountInfoVC alloc]init];
        [self.navigationController pushViewController:infoVC animated:YES];
    }
    
    return;
}



@end
