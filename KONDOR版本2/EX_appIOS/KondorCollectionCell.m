//
//  KondorCollectionCell.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "KondorCollectionCell.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+WaterMark.h"

@implementation KondorCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    _photoImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _photoImg.userInteractionEnabled=YES;
    [self addSubview:_photoImg];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hasTapRecognize)];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapHasClicked:)];
    [self.photoImg addGestureRecognizer:longGesture];
//    longGesture.numberOfTapsRequired=1;
//    longGesture.minimumPressDuration=0.8;
//    UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapHasClicked)];
//    [doubleTap setNumberOfTapsRequired:2];
    //    [self.photoImg addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:longGesture];
    
    [self.photoImg addGestureRecognizer:tap];
    
    return self;
    
}

//长按事件
-(void)longTapHasClicked:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
    if (_hasSelected==NO) {

        _hasSelected=YES;
    }else{
        _hasSelected=NO;
    }
    
//    [self addSubview:self.MYmaskView];
    
    if ([self.delegate respondsToSelector:@selector(doubletapDidClicked)]) {
        [self.delegate doubletapDidClicked];
    }
    }
}
//  单击事件
-(void)hasTapRecognize{
    
     _hasdoubleSelected=YES;
    
    if ([self.delegate respondsToSelector:@selector(cellDidSelected)]) {
        [self.delegate cellDidSelected];
    }
    
}

// 蒙版长按
-(void)MaskViewLongTap{
    
    
}



-(void)removeMaskView{
    _hasSelected=NO;
    [self.MYmaskView removeFromSuperview];
//    if ([self.delegate respondsToSelector:@selector(cellDidSelected)]) {
//        [self.delegate cellDidSelected];
//    }
}



-(UIImageView *)MYmaskView
{
    if (_MYmaskView==nil) {
        _MYmaskView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _MYmaskView.userInteractionEnabled=YES;
        _MYmaskView.backgroundColor=[UIColor clearColor];
        UIImageView *selectedTip=[[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width-20), 0, 20, 20)];
        selectedTip.image=[UIImage imageNamed:@"selectedImage"];
        [_MYmaskView addSubview:selectedTip];
        
        
        _MYmaskView.alpha=1;
        UITapGestureRecognizer *tap1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hasTapRecognize)];
        [_MYmaskView addGestureRecognizer:tap1];
        
        UILongPressGestureRecognizer *longGesture2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapHasClicked:)];
        [_MYmaskView addGestureRecognizer:longGesture2];
        [tap1 requireGestureRecognizerToFail:longGesture2];
        
    }
    return _MYmaskView;
}


-(void)setPhotoName:(NSString *)photoName
{
    _photoName=photoName;
    
    _photoImg.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",photoName]];
    
}
-(void)setModel:(KondonPhotoModel *)model
{
    _model=model;
    //如果是视频
    if (model.isVideo==YES) {
        
        
//        [UIImage imageNamed:@"EX_App_MAIN MENU_LOGO"]
        UIImage * newimg=[UIImage OriginImage:[UIImage imageNamed:@"loadingLogo"] scaleToSize:CGSizeMake(100, 100) withLogoImage:[UIImage imageNamed:@"play"] scale:4];
        
        [_photoImg setCurrentImage:newimg withURL:model.pathUrl withQueue:self.cellque withSize:CGSizeMake(100, 100) withScale:4.0];
   
       

    }else{
        
        if ([model.pathUrl.description hasPrefix:@"http"]) {
//            [_photoImg sd_setImageWithURL:model.pathUrl placeholderImage:[UIImage imageNamed:@"EX_App_MAIN MENU_LOGO"] options:SDWebImageScaleDownLargeImages|SDWebImageCacheMemoryOnly  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                
//                if (image!=nil) {
//                    UIImage *img=[self imageByScalingAndCroppingForSize:CGSizeMake(100, 100) WithImage:image];
//                    
//                    [_photoImg setImage:img];
//                    
//                }else{
//                    
//                    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
//                    label.text=@"TIME OUT";
//                    label.textAlignment=NSTextAlignmentCenter;
//                    label.textColor=[UIColor whiteColor];
//                    label.font=[UIFont systemFontOfSize:15];
//                    [self addSubview:label];
//                }
//                
//            }];
            
            
            _photoImg.image=[UIImage imageNamed:@"loadingLogo"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data=[NSData dataWithContentsOfURL:model.pathUrl];
               
                UIImage *dataImg=[UIImage imageWithData:data];
                UIImage *img=[UIImage OriginImage:dataImg scaleToSize:CGSizeMake(100, 100)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (img!=nil) {
                        _photoImg.image=img;
                    }
                });
                
            });
            
            
            
        }else{

            _photoImg.image=[UIImage imageNamed:@"loadingLogo"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *dataImg=[UIImage imageWithContentsOfFile:model.pathUrl.description];
                UIImage *img=[UIImage OriginImage:dataImg scaleToSize:CGSizeMake(100, 100)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (img!=nil) {
                        _photoImg.image=img;
                    }
                });
                
            });
            
            
//            [_photoImg sd_setImageWithURL:model.pathUrl placeholderImage:[UIImage imageNamed:@"EX_App_MAIN MENU_LOGO"] options:SDWebImageScaleDownLargeImages];
//            [_photoImg sd_setImageWithURL:model.pathUrl placeholderImage:[UIImage imageNamed:@"EX_App_MAIN MENU_LOGO"]];
        }
   
        
    }
    
}







//图片压缩到指定大小
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize WithImage:(UIImage *)img
{
    UIImage *sourceImage = img;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

-(NSMutableArray *)generatorArr
{
    if (_generatorArr==nil) {
        _generatorArr=[NSMutableArray array];
    }
    
    return _generatorArr;
}

@end
