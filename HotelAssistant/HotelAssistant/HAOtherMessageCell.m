//
//  HAOtherMessageCell.m
//  HotelAssistant
//
//  Created by 伍陶陶 on 2017/8/5.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAOtherMessageCell.h"

@implementation HAOtherMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)otherMessageCellWithTableView:(UITableView *)tableView
{
    
    HAOtherMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherMessageCell"];
    if(cell==nil){
        cell = [[NSBundle mainBundle] loadNibNamed:@"HAOtherMessageCell" owner:self options:nil].lastObject;
        
    }
    return cell;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
