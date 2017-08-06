//
//  HAPersonCenterVC.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAPersonCenterVC.h"
#import "HAPersonCenterCell.h"
#import "HAPersonInfoVC.h"
#import "HAMyOrderVC.h"
#import "HAMyMoneyVC.h"
#import "HAupdatePersonInfoVC.h"


@interface HAPersonCenterVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (weak, nonatomic) IBOutlet UIImageView *personAdvaer;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *experienceLabel;



@end

@implementation HAPersonCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 3;
    }
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAPersonCenterCell *cell = [HAPersonCenterCell personCenterCellWithTableView:tableView];
    
    cell.personindex = indexPath;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        HAPersonInfoVC *infoVC = [[HAPersonInfoVC alloc]init];
        
        [self.navigationController pushViewController:infoVC animated:YES];
    }else if (indexPath.section==0&&indexPath.row==1){
        
        HAMyOrderVC *orderVC = [[HAMyOrderVC alloc]init];
        
          [self.navigationController pushViewController:orderVC animated:YES];
        
    }else if (indexPath.section==0&&indexPath.row==2){
        
        HAMyMoneyVC *monkeyVC = [[HAMyMoneyVC alloc]init];
        
        [self.navigationController pushViewController:monkeyVC animated:YES];
        
    }else if (indexPath.section==1&&indexPath.row==0){
        
        HAupdatePersonInfoVC *infoVC = [[HAupdatePersonInfoVC alloc]init];
        
        [self.navigationController pushViewController:infoVC animated:YES];
        
    }
    
}





@end
