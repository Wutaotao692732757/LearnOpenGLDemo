//
//  FeedBackButton.m
//  EX_appIOS
//
//  Created by wutaotao on 2017/2/12.
//  Copyright © 2017年 aee. All rights reserved.
//

#import "FeedBackButton.h"

@implementation FeedBackButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    if (self) {
        [self addTarget:self action:@selector(changgeBackGroundcolor:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}



-(void)changgeBackGroundcolor:(UIButton *)btn{
    
    btn.backgroundColor=[UIColor lightGrayColor];
    
}


@end
