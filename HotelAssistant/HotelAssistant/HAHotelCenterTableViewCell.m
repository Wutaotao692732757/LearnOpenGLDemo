//
//  HAHotelCenterTableViewCell.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/13.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAHotelCenterTableViewCell.h"

@implementation HAHotelCenterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)hotelCenterCellInitWithTableView:(UITableView *)tableview{
    
    HAHotelCenterTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"hotelcentercell"];
    
    if (cell==nil) {
        cell=[[NSBundle mainBundle] loadNibNamed:@"HAHotelCenterTableViewCell" owner:self options:nil].lastObject;
    }
    
    return cell;
}

-(void)setMyindex:(NSIndexPath *)myindex
{
    switch (myindex.row) {
        case 0:
            _iconImage.image=[UIImage imageNamed:@"账户资料icon"];
            _nameLabel.text=@"账户资料";
            break;
        case 1:
            _iconImage.image=[UIImage imageNamed:@"子账户管理icon"];
            _nameLabel.text=@"子账户资料";
            
            break;
        case 2:
            _iconImage.image=[UIImage imageNamed:@"余额icon"];
            _nameLabel.text=@"余额";
            
            break;
        case 3:
            _iconImage.image=[UIImage imageNamed:@"投诉icon"];
            _nameLabel.text=@"投诉管理";
            
            break;
        case 4:
            _iconImage.image=[UIImage imageNamed:@"设置icon"];
            _nameLabel.text=@"设置";
            
            break;
            
        default:
            break;
    }
    
    
    
    
}




@end
