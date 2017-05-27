//
//  KondorSectionHeaderView.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "KondorSectionHeaderView.h"

@implementation KondorSectionHeaderView


-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    _tipsLabel=[[UILabel alloc]init];
    
    _tipsLabel.font=[UIFont fontWithName:@"DINOffc-Medi" size:17];
    _tipsLabel.textColor=[UIColor whiteColor];
    _tipsLabel.textAlignment=NSTextAlignmentLeft;
    _tipsLabel.frame=CGRectMake(10, 0, ScreenW-20, frame.size.height);
    [self addSubview:_tipsLabel];
    return self;
}



-(void)setTips:(NSString *)tips
{
    _tipsLabel.text=tips;
    
    
}

@end
