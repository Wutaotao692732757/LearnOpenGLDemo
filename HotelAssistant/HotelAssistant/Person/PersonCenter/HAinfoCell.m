//
//  HAinfoCell.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAinfoCell.h"


@implementation HAinfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)HAinfoCellWithTableView:(UITableView *)tableView{
    
    HAinfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HAinfoCellID"];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HAinfoCell" owner:self options:nil].lastObject;
    }
    
    return cell;
    
    
}
 
-(void)setInfoCellPath:(NSIndexPath *)infoCellPath
{
    
    if (_infoCellPath==nil) {
        _infoCellPath = infoCellPath;
    }
    
    switch (infoCellPath.row) {
        case 0:
            _ICON.image = [UIImage imageNamed:@"头像ICON"];
            _NameLabel.text = @"头像";
            _tipLabel.hidden=YES;
            _personAdver.hidden=NO;
            
            break;
        case 1:
            _ICON.image = [UIImage imageNamed:@"个人昵称icon"];
            _NameLabel.text = @"昵称";
            _tipLabel.text = @"我是小白";
            break;
        case 2:
            _ICON.image = [UIImage imageNamed:@"电话icon"];
            _NameLabel.text = @"联系电话";
            _tipLabel.text = @"13658745874";
            break;
        case 3:
            _ICON.image = [UIImage imageNamed:@"酒店星级"];
            _NameLabel.text = @"综合好评数";
            _tipLabel.text = @"4";
            break;
        case 4:
            _ICON.image = [UIImage imageNamed:@"微信icon"];
            _NameLabel.text = @"绑定微信";
            _tipLabel.text = @"已经绑定(可用微信登录)";
            break;
            
        default:
            break;
    }
    
    
}



@end
