//
//  HAPersonCenterCell.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAPersonCenterCell.h"

#define personCenterCellId @"personcentercell"

@implementation HAPersonCenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


+(instancetype)personCenterCellWithTableView:(UITableView *)tableView{
    
    HAPersonCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:personCenterCellId];
    
    
    if (cell==nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HAPersonCenterCell"owner:self options:nil].lastObject;
    }
    
    return cell;
    
    
}

-(void)setPersonindex:(NSIndexPath *)personindex
{
    if (personindex.section==0) {
        
        switch (personindex.row) {
            case 0:
                _cellIconImage.image = [UIImage imageNamed:@"账户资料icon"];
                _cellNamelabel.text = @"个人信息";
                break;
            case 1:
                _cellIconImage.image = [UIImage imageNamed:@"子账户管理icon"];
                _cellNamelabel.text = @"我的订单";
                break;
            case 2:
                _cellIconImage.image = [UIImage imageNamed:@"余额icon"];
                _cellNamelabel.text = @"我的钱包";
                break;
                
            default:
                break;
        }
        
        
    }else{
        
        switch (personindex.row) {
            case 0:
                _cellIconImage.image = [UIImage imageNamed:@"完善个人资料icon"];
                _cellNamelabel.text = @"完善个人资料";
                break;
            case 1:
                _cellIconImage.image = [UIImage imageNamed:@"设置icon"];
                _cellNamelabel.text = @"系统设置";
                break;
                
            default:
                break;
        }
        
    }
    
    
}







@end
