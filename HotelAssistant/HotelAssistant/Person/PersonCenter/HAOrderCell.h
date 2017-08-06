//
//  HAOrderCell.h
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAOrderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;

@property (weak, nonatomic) IBOutlet UILabel *begintimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *successTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *payLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectNumlabel;


+(instancetype)HAordercellWithtableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UIButton *beginscanBtn;


@end










