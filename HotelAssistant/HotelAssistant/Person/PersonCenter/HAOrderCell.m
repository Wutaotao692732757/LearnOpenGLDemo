//
//  HAOrderCell.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAOrderCell.h"
#define  OdercellReuseID  @"OdercellReuseID"

@implementation HAOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

+(instancetype)HAordercellWithtableView:(UITableView *)tableView{
    
    HAOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:OdercellReuseID];
    
    
    if (cell==nil) {
     cell = [[NSBundle mainBundle] loadNibNamed:@"HAOrderCell" owner:self options:nil].lastObject;
    }
    
    return cell;
    
}
- (IBAction)beginScanbtnDidClicked:(id)sender {
    
    
}


@end
