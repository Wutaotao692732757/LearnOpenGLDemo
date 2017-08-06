//
//  HAPersonCenterCell.h
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAPersonCenterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellNamelabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellIconImage;
 

+(instancetype)personCenterCellWithTableView:(UITableView *)tableView;


@property (nonatomic ,strong)NSIndexPath *personindex;
@end
