//
//  UIImage+WaterMark.m
//  AEE
//
//  Created by AEE_ios on 16/5/19.
//  Copyright © 2016年 AEE_ios. All rights reserved.
//

#import "UIImage+WaterMark.h"

@implementation UIImage (WaterMark)

- (UIImage *)waterMarkImage:(NSString *)text showTitleColor:(UIColor*)lor
{
    //获取上下文
    UIGraphicsBeginImageContext(self.size);
    //绘制图片
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //绘制水印文字
    CGRect rect = CGRectMake(30, 10, self.size.width -60, self.size.height);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    //文字属性
    NSDictionary *dic = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],
                          NSParagraphStyleAttributeName:style,
                          NSForegroundColorAttributeName:lor
                          };
    //将文字绘制上去
    [text drawInRect:rect withAttributes:dic];
    //获取绘制的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束当前图片绘制
    UIGraphicsEndImageContext();
    return image; 
    
}

+(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size
{
    if (image == nil) {
        return nil;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaleImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}
+(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size withModeSize:(CGSize)scaleSize
{
    if (image == nil) {
        return nil;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(size.width/2-scaleSize.width/2,size.height/2-scaleSize.height/2, scaleSize.width, scaleSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage* scaleImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}
//给图片中间加水印，显示为视频文件
+(UIImage*)OriginImage:(UIImage*)image scaleToSize:(CGSize)size withLogoImage:(UIImage *)img scale:(float)scale{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [img drawInRect:CGRectMake((size.width-size.width/scale)/2.0, (size.height-size.height/scale)/2.0, size.width/scale, size.height/scale)];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}
@end
