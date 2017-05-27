//
//  UIImage+WaterMark.h
//  AEE
//
//  Created by AEE_ios on 16/5/19.
//  Copyright © 2016年 AEE_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WaterMark)

//获取水印文字
- (UIImage *) waterMarkImage:(NSString *)text showTitleColor:(UIColor*)lor;
+ (UIImage *) OriginImage:(UIImage*)image scaleToSize:(CGSize)size;
+ (UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size withModeSize:(CGSize)scaleSize;
+ (UIImage *) OriginImage:(UIImage*)image scaleToSize:(CGSize)size withLogoImage:(UIImage *)img scale:(float)scale;
@end
