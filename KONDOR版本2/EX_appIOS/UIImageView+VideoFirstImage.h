//
//  UIImageView+VideoFirstImage.h
//  EX_appIOS
//
//  Created by mac_w on 2016/12/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (VideoFirstImage)
@property(nonatomic,strong)NSMutableArray *generatorArr;
- (void)setCurrentImage:(UIImage*)holdimage withURL:(NSURL*)url withQueue:(dispatch_queue_t)queue withSize:(CGSize)size withScale:(CGFloat)scale;
@end
