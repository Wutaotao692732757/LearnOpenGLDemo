//
//  modelSelectView.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/11.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "modelSelectView.h"

@implementation modelSelectView

-(instancetype)init
{
    return [[NSBundle mainBundle] loadNibNamed:@"modelSelectView" owner:self options:nil].lastObject;
}


- (IBAction)changeBackGroundColor:(id)sender {
    
    UIButton *btn =sender;
        UIView *cellView = btn.superview;
        cellView.backgroundColor=[UIColor lightGrayColor];
}

- (IBAction)changeBackgroundColor2:(id)sender {
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor lightGrayColor];
}

- (IBAction)changeBackGroundColor3:(id)sender {
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor lightGrayColor];
}

- (IBAction)changeBackGroundColor4:(id)sender {
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor lightGrayColor];
}

- (IBAction)changeBackGroundColor5:(id)sender {
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor lightGrayColor];
    
}

- (IBAction)closeBtnDidClicked:(id)sender {
 
    [self removeFromSuperview];
}

- (IBAction)CamerBtnDidClicked:(id)sender {
    
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor colorWithRed:65/255.0 green:65/255.0 blue:65/255.0 alpha:1];
    
    if ([self.delegate respondsToSelector:@selector(customerChoiceCameraModelWithCount:)]) {
        [self.delegate customerChoiceCameraModelWithCount:1];
    }
    
    [self removeFromSuperview];
}

- (IBAction)videoBtnDidClicked:(id)sender {
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor colorWithRed:65/255.0 green:65/255.0 blue:65/255.0 alpha:1];
    
    if ([self.delegate respondsToSelector:@selector(customerChoiceCameraModelWithCount:)]) {
        [self.delegate customerChoiceCameraModelWithCount:2];
    }
     [self removeFromSuperview];
}

- (IBAction)BurstBtnDidClicked:(id)sender {
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor colorWithRed:65/255.0 green:65/255.0 blue:65/255.0 alpha:1];
    
    if ([self.delegate respondsToSelector:@selector(customerChoiceCameraModelWithCount:)]) {
        [self.delegate customerChoiceCameraModelWithCount:3];
    }
     [self removeFromSuperview];
}

- (IBAction)timerBtnDidClicked:(id)sender {
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor colorWithRed:65/255.0 green:65/255.0 blue:65/255.0 alpha:1];
    if ([self.delegate respondsToSelector:@selector(customerChoiceCameraModelWithCount:)]) {
        [self.delegate customerChoiceCameraModelWithCount:4];
    }
     [self removeFromSuperview];
}


- (IBAction)timerLapsePhotoDidClicked:(id)sender {
    UIButton *btn =sender;
    UIView *cellView = btn.superview;
    cellView.backgroundColor=[UIColor colorWithRed:65/255.0 green:65/255.0 blue:65/255.0 alpha:1];
    if ([self.delegate respondsToSelector:@selector(customerChoiceCameraModelWithCount:)]) {
        [self.delegate customerChoiceCameraModelWithCount:5];
    }
    [self removeFromSuperview];
    
}



@end
