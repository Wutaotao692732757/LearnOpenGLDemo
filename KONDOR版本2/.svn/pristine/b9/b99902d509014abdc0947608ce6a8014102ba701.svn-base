//
//  UIButton+AEEButton.m
//  AEE
//
//  Created by AEE_ios on 16/5/20.
//  Copyright © 2016年 AEE_ios. All rights reserved.
//

#import "UIButton+AEEButton.h"

@implementation UIButton (AEEButton)

- (void)setImage:(UIImage *)image text:(NSString *)text leftMargin:(CGFloat)leftMargin
{
    [self setImage:image forState:UIControlStateNormal];
    [self setImageEdgeInsets:UIEdgeInsetsMake(10, leftMargin, 10, 110)];
    [self setTitle:text forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(5, 20+leftMargin, 5, 10)];
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

@end
