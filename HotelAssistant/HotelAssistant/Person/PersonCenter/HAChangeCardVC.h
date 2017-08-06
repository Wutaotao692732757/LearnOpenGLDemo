//
//  HAChangeCardVC.h
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAChangeCardVC : UIViewController
@property (nonatomic,copy) NSString *nameTitle;

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *cardtext;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;


@end
