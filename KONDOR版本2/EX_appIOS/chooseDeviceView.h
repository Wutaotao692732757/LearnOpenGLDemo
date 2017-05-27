//
//  chooseDeviceView.h
//  EX_appIOS
//
//  Created by mac_w on 2016/11/28.
//  Copyright © 2016年 aee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol chooseViewDelegate <NSObject>

@optional
-(void)chooseViewButtonDidClicked:(UIButton *)button;

@end


@interface chooseDeviceView : UIView

@property(nonatomic,weak)id<chooseViewDelegate> delegate;

@end
