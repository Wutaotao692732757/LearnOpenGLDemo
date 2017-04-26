//
//  ViewController.m
//  ch3-1
//
//  Created by wutaotao on 2017/4/25.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
typedef enum
{
    AGLK1 = 1,
    AGLK2 = 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
}
AGLKPowerOf2;
@interface ViewController ()


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    UIImage *sourceImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leaves" ofType:@"gif"]]];
    CGImageRef cgImage = sourceImg.CGImage;
    
    size_t originalWidth = CGImageGetWidth(cgImage);
    size_t originalHeight = CGImageGetHeight(cgImage);
    
    
    


}

static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(GLuint dimension){
    
    AGLKPowerOf2 result = AGLK1;
    if (dimension > (GLuint)AGLK512) {
        result = AGLK1024;
    }else if (dimension > (GLuint)AGLK256){
        
    }
    
    
    
    
    
    return result;
}




@end

























