//
//  ViewController.m
//  scanCard
//
//  Created by wutaotao on 2017/7/22.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
//http://u.wechat.com/EApSqiGlTZPTfMVsqfqtZc8
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *img = [UIImage imageNamed:@"IMG_5880.JPG"];
    NSLog(@"得到的结果是%@",[self decodeQRImageWith:img]);
    
    self.resultImage.image = [self encodeQRImageWithContent:@"http://u.wechat.com/EApSqiGlTZPTfMVsqfqtZc8" size:CGSizeMake(400, 400)];
    
    
 
    NSData *imgdata = UIImagePNGRepresentation(self.resultImage.image);
    
    NSString *path0 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *pathresult = [NSString stringWithFormat:@"%@/%@",path0,@"hello.png"];
    NSLog(@"路劲是什么%@",pathresult);
    [imgdata writeToFile:pathresult atomically:YES];
    
    UIImageWriteToSavedPhotosAlbum(self.resultImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo { NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo); }


-(NSString *)decodeQRImageWith:(UIImage *)aImage{
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:aImage.CGImage];
    
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    
    NSString *qrResult = feature.messageString;
    return qrResult;
}

- (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size { UIImage *codeImage = nil;
    NSData *stringData = [content dataUsingEncoding: NSUTF8StringEncoding];
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    UIColor *onColor = [UIColor redColor];
    UIColor *offColor = [UIColor whiteColor];
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues: @"inputImage",qrFilter.outputImage, @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor], @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor], nil];
    CIImage *qrImage = colorFilter.outputImage;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, 1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
//    UIImage *imgcenter = [UIImage imageNamed:@"IMG_5879.JPG"];
//    CGFloat centerW=100;
//    CGFloat centerH=100;
//    CGFloat centerX=300;
//    CGFloat centerY=300;
//    [imgcenter drawInRect:CGRectMake(centerX, centerY, centerW, centerH)];
    
    
//    IMG_5881.JPG
    
    UIImage *imgcenter2 = [UIImage imageNamed:@"IMG_5879.JPG"];
    CGFloat centerW2=100;
    CGFloat centerH2=100;
    CGFloat centerX2=(400-100)*0.5-2 ;
    CGFloat centerY2=(400-100)*0.5;
    [imgcenter2 drawInRect:CGRectMake(centerX2, centerY2, centerW2, centerH2)];
    
 
    codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return codeImage;
}
    
  


@end
