//
//  HAHotelCenterTableViewCell.h
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/13.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAHotelCenterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic,assign) NSIndexPath *myindex;


+(instancetype)hotelCenterCellInitWithTableView:(UITableView *)tableview;



@end
