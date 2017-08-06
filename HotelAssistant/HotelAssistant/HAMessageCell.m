//
//  HAMessageCell.m
//  HotelAssistant
//
//  Created by 伍陶陶 on 2017/8/5.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAMessageCell.h"

#define cellreuseidenty @"messageCell"

@implementation HAMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


+(instancetype)initMessageCellWithTableView:(UITableView *)tableView{
 
    HAMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellreuseidenty];
    
    if (cell==nil) {
//        cell=[[HAMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellreuseidenty];
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"HAMessageCell" owner:self options:nil].lastObject;
    }
    
    return cell;
    
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
