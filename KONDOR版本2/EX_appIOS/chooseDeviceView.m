//
//  chooseDeviceView.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/28.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "chooseDeviceView.h"

@implementation chooseDeviceView

- (IBAction)choseButtonTouchDown:(UIButton *)sender {
 
    sender.backgroundColor=[UIColor lightGrayColor];
   
}
 
- (IBAction)choseViewButtonDidClicked:(UIButton *)sender {
    
    if (sender.tag==2) {
        sender.backgroundColor=[UIColor redColor];
    }else{
        
        sender.backgroundColor=[UIColor darkGrayColor];
    }
    
    
    NSLog(@"dailidainjile ");
    if ([self.delegate respondsToSelector:@selector(chooseViewButtonDidClicked:)]) {
        
        [self.delegate chooseViewButtonDidClicked:sender];
    }
}


@end
