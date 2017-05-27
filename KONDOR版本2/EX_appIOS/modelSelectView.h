//
//  modelSelectView.h
//  EX_appIOS
//
//  Created by mac_w on 2016/11/11.
//  Copyright © 2016年 aee. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol choiceCameraModelDelegate <NSObject>

@optional

-(void)customerChoiceCameraModelWithCount:(NSInteger)count;

@end

@interface modelSelectView : UIView


@property(nonatomic,weak)id<choiceCameraModelDelegate>delegate;

@end
