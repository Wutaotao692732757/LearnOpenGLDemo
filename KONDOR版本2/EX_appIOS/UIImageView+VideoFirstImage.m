//
//  UIImageView+VideoFirstImage.m
//  EX_appIOS
//
//  Created by mac_w on 2016/12/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "UIImageView+VideoFirstImage.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+WaterMark.h"
#import <objc/runtime.h>
static char flashKey;
@implementation UIImageView (VideoFirstImage)


-(void)setGeneratorArr:(NSMutableArray *)generatorArr
{
    objc_setAssociatedObject(self, &flashKey, generatorArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSMutableArray *)generatorArr
{
    return objc_getAssociatedObject(self, &flashKey);
}


//获取视频URL第一张图片
- (void)setCurrentImage:(UIImage*)holdimage withURL:(NSURL*)url withQueue:(dispatch_queue_t)queue withSize:(CGSize)size withScale:(CGFloat)scale{
    
    self.image=holdimage;

        dispatch_async(queue, ^{

        NSString *urlstring = url.description;
        NSLog(@"-----地址 --- %@---%@",urlstring,queue);
//          // 第一种方式
//        NSURL *newurl = [NSURL URLWithString:urlstring];
//        AVAsset *urlSet = [AVAsset assetWithURL:url];
//        UIImage*thumbnail =  [moviePlayer thumbnailImageAtTime:time    timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        AVURLAsset *urlSet = [[AVURLAsset alloc]initWithURL:url options:nil];
    
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc]initWithAsset:urlSet];
        generator.appliesPreferredTrackTransform = YES;
        generator.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture;
        generator.maximumSize=CGSizeMake(200, 200);
//        CGImageRef thumbnailImageRef = NULL;
//        CFTimeInterval thumbnailImageTime = time;
//        NSError *thumbnailImageGenerationError = nil;
//        thumbnailImageRef = [generator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, urlSet.duration.timescale)actualTime:NULL error:&thumbnailImageGenerationError];
//        
//        if(!thumbnailImageRef)
//            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
//        
//        UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
//        if (thumbnailImage==nil) return ;
//        dispatch_async(dispatch_get_main_queue(), ^{
//                                UIImage *img = [UIImage OriginImage:thumbnailImage scaleToSize:CGSizeMake(100.0, 100.0) withLogoImage:ImgNamed(@"play") scale:3.5];
//                                [self setImage:img];
//                            });

        CMTime time = CMTimeMake(0.1, 30);
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            UIImage *thumbImg = [UIImage imageWithCGImage:image];
            if (result == AVAssetImageGeneratorSucceeded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *img = [UIImage OriginImage:thumbImg scaleToSize:size withLogoImage:ImgNamed(@"play") scale:scale];
                    [self setImage:img];
                });
   
            }
        };
        generator.maximumSize = CGSizeMake(200, 200);
        [generator generateCGImagesAsynchronouslyForTimes:
         [NSArray arrayWithObject:[NSValue valueWithCMTime:time]] completionHandler:handler];
   
    });
    
}
@end
