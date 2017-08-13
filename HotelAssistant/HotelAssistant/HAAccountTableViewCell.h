//
//  HAAccountTableViewCell.h
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/13.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAAccountTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *advaerImage;

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backArrow;

@property (nonatomic,strong) NSIndexPath *myindex;


+(instancetype)accountCellWithtableView:(UITableView *)tableView;



@end
