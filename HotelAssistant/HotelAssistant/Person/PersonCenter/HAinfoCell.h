//
//  HAinfoCell.h
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAinfoCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *ICON;
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *personAdver;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;


+(instancetype)HAinfoCellWithTableView:(UITableView *)tableView;


@property (nonatomic,strong) NSIndexPath *infoCellPath;


@end
