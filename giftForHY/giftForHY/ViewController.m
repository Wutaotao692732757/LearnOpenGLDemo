//
//  ViewController.m
//  giftForHY
//
//  Created by wutaotao on 2017/6/9.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#define VideoWidth  96*30
#define VideoHeight 128*15
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *resultimage;

@property (weak, nonatomic) IBOutlet UIImageView *aphImage;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

-(UIImage*)drawImageForHy{
    
    
    UIGraphicsBeginImageContextWithOptions (CGSizeMake(VideoWidth, VideoHeight), NO , 0.0 );
  
//    CGContextRef context = UIGraphicsGetCurrentContext();
    for (int i = 0 ; i<344; i++) {
        
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"IMG_%zd.JPG",5143+i]];
        [img drawInRect:CGRectMake((i%30)*96, (i/30)*128, 96, 128) blendMode:kCGBlendModeNormal alpha:0.8];
//        [img drawInRect:CGRectMake((i%20)*400, (i/20)*400, 400, 400)];
    }
    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    
    
    UIImage *bigImg = [self imageBlackToTransparent:[UIImage imageNamed:@"bigPic.JPG"]];
//    [UIImage imageNamed:@"big.png"];
    [bigImg drawInRect:CGRectMake( 0, 0, VideoWidth, VideoHeight) blendMode:kCGBlendModeNormal alpha:0.9];
    
    UIImage * nameImg = [UIImage imageNamed:@"1655"];
    
    [nameImg drawInRect:CGRectMake(0, VideoHeight-500, 800, 500) blendMode:kCGBlendModeNormal alpha:1.0];
 
//    CGContextDrawPath (context, kCGPathStroke );
//    
//    NSString *string = @"happy new year";
////    CGSize size=[string sizeWithAttributes:@{NSFontAttributeName: [ UIFont fontWithName:@"Party LET" size: 50],NSKernAttributeName:@10}];
//    [string drawInRect:CGRectMake(0, VideoHeight, 4000, 4000) withAttributes:@{ NSFontAttributeName :[ UIFont fontWithName:@"Party LET" size: 500],NSKernAttributeName:@10, NSForegroundColorAttributeName :[ UIColor blackColor ] }];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext ();
    return newImage;
}


- (IBAction)playBtnDidclicked:(id)sender {
    
    UIImage *resultImage = [self drawImageForHy];
    self.resultimage.image = resultImage;
    
   UIImageWriteToSavedPhotosAlbum(resultImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    UIImage *imagesave = resultImage;
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/test.png"];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(imagesave) writeToFile:imagePath atomically:YES];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo { //
    
    if(error!=nil){
        
        NSLog(@"save error");
    }else{
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSLog(@"%@", paths[0]);
        //        [SVProgressHUD showErrorWithStatus:@"save success"];
    }
    
    
}
void ProviderReleaseData (void *info, const void *data, size_t size)

{
    
    free((void*)data);
    
}
- (UIImage*) imageBlackToTransparent:(UIImage*) image

{
    
    // 分配内存
    
    const int imageWidth = image.size.width;
    
    const int imageHeight = image.size.height;
    
    size_t      bytesPerRow = imageWidth * 4;
    
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    
    
    // 创建context
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
 
    // 遍历像素
    
    int pixelNum = imageWidth * imageHeight;
    
    uint32_t* pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < pixelNum; i++, pCurPtr++)
        
    {
        
         uint8_t* ptr = (uint8_t*)pCurPtr;
       
        int scale = (i % imageWidth )*(255*1.0/imageWidth);
  
              ptr[0] = scale;
//        if (imageWidth*0.1>(i % imageWidth )>imageWidth*0.2){
//            ptr[0] = 0;
//        }else if (imageWidth*0.2>(i % imageWidth )>imageWidth*0.3){
//            ptr[0] = 20;
//        }
//        else if (imageWidth*0.3>(i % imageWidth )>imageWidth*0.4){
//            ptr[0] = 20;
//        }
//        else if (imageWidth*0.4>(i % imageWidth )>imageWidth*0.5){
//            ptr[0] = 20;
//        }else if (imageWidth*0.6>(i % imageWidth )>imageWidth*0.5) {
//              ptr[0] = 150;
//        }else if (imageWidth*0.7>(i % imageWidth )>imageWidth*0.6){
//            ptr[0] = 100;
//        }else if (imageWidth*0.8>(i % imageWidth )>imageWidth*0.7){
//            ptr[0] = 255;
//        }else if (imageWidth*0.9>(i % imageWidth )>imageWidth*0.8){
//            ptr[0] = 255;
//        }else if (imageWidth*1.0>(i % imageWidth )>imageWidth*0.9){
//            ptr[0] = 255;
//        }
 
        if ((*pCurPtr & 0xFFFFFF00) == 0xffffff00)    // 将白色变成透明
            
        {
            
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//            
//            ptr[0] = 0;
            
        }
        
        else
            
        {
            
            // 改成下面的代码，会将图片转成想要的颜色
            
//            uint8_t* ptr = (uint8_t*)pCurPtr;
            
//            ptr[3] = 0; //0~255
//            
//            ptr[2] = 0;
//            
//            ptr[1] = 0;
//              ptr[0] = 22;
            
        }
        
        
        
    }
    
    
    
    // 将内存转成image
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        
                                        NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    
    
    // 释放
    
    CGImageRelease(imageRef);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    // free(rgbImageBuf) 创建dataProvider时已提供释放函数，这里不用free
    
    
    
    return resultUIImage;
    
}


- (IBAction)changeAplha:(id)sender {
    
    UIImage *newimg = [self imageBlackToTransparent:[UIImage imageNamed:@"big"]];
    self.aphImage.image=newimg;
    
}





@end
