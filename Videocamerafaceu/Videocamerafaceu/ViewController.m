//
//  ViewController.m
//  Videocamerafaceu
//
//  Created by wutaotao on 2017/5/27.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()<GPUImageVideoCameraDelegate>

@property (nonatomic,strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic,strong) GPUImageUIElement *element;
@property (nonatomic,strong) GPUImageView *filterView;

@property (nonatomic,strong) UIView *elementView;
@property (nonatomic,strong) UIImageView *capImageView;
@property (nonatomic,assign) CGRect faceBounds;
@property (nonatomic,strong) CIDetector *faceDetector;

@property (nonatomic,assign) BOOL faceThinking;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.delegate = self;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = self;
    
    GPUImageFilter *filter = [[GPUImageFilter alloc] init];
    [self.videoCamera addTarget:filter];
    
    self.element = [[GPUImageUIElement alloc]initWithView:self.elementView];
    GPUImageAlphaBlendFilter *blendFilter  = [[GPUImageAlphaBlendFilter alloc]init];
    blendFilter.mix = 1.0;
    [filter addTarget:blendFilter];
    [self.element addTarget:blendFilter];
    
    self.filterView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    self.filterView.center = self.view.center;
    [self.view addSubview:self.filterView];
    [blendFilter addTarget:self.filterView];
    
    __weak typeof (self) weakSelf = self;
    
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time){
        __strong typeof (self) strongSelf = weakSelf;
        CGRect rect = strongSelf.faceBounds;
        CGSize size = strongSelf.capImageView.frame.size;
        strongSelf.capImageView.frame = CGRectMake(rect.origin.x +  (rect.size.width - size.width)/2, rect.origin.y - size.height, size.width, size.height);
        [strongSelf.element update];
        
    }];
    
    [self.videoCamera startCameraCapture];
    
}

-(void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (!_faceThinking) {
        CFAllocatorRef allocator = CFAllocatorGetDefault();
        CMSampleBufferRef sbufCopyOut;
        CMSampleBufferCreateCopy(allocator, sampleBuffer, &sbufCopyOut);
        
        [self performSelectorInBackground:@selector(grepFacesForSampleBuffer:) withObject:CFBridgingRelease(sbufCopyOut)];
    }
}

-(void)grepFacesForSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    _faceThinking = YES;
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc]initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary*)attachments];
    
    if (attachments) CFRelease(attachments);
    
    NSDictionary *imageoptions = nil;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    int exifOrientation;
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    BOOL isUsingFrontFacingCamera = FALSE;
    AVCaptureDevicePosition currentCameraposition = [self.videoCamera cameraPosition];
    
    if (currentCameraposition != AVCaptureDevicePositionBack) {
        isUsingFrontFacingCamera = TRUE;
    }
    
    switch (curDeviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:
            
            if (isUsingFrontFacingCamera) {
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            }else{
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            }
            
            break;
        case UIDeviceOrientationPortrait:
        default:exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    
    imageoptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    NSArray *features = [self.faceDetector featuresInImage:convertedImage options:imageoptions];
    
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);
    
    [self GPUVCWilloutputFeatures:features forClap:clap andOrientation:curDeviceOrientation];
    _faceThinking = NO;
    
}

-(void)GPUVCWilloutputFeatures:(NSArray *)featureArray forClap:(CGRect)clap
                andOrientation:(UIDeviceOrientation)curDeviceOrientation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect previewBox = self.view.frame;
        
        if (featureArray.count) {
            self.capImageView.hidden = NO;
        }else{
            self.capImageView.hidden = YES;
        }
        
        for (CIFaceFeature *faceFeature in featureArray) {
            
            CGRect faceRect = [faceFeature bounds];
            CGFloat temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            
            CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
            CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
            
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
            faceRect.origin.y *= heightScaleBy;
            
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            
            CGRect rect = CGRectMake(previewBox.size.width-faceRect.origin.x-faceRect.size.width, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
            
            if (fabs(rect.origin.x - self.faceBounds.origin.x) > 5.0) {
                self.faceBounds = rect;
            }
            
        }
    });
}

//
-(CIDetector *)faceDetector
{
    if (!_faceDetector) {
        NSDictionary *detectorOptions = [[NSDictionary alloc]initWithObjectsAndKeys:CIDetectorAccuracyLow,CIDetectorAccuracy, nil];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    }
    return _faceDetector;
}

-(UIView *)elementView
{
    if (!_elementView) {
        _elementView = [[UIView alloc]initWithFrame:self.view.frame];
        _capImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 160, 160)];
        [_capImageView setImage:[UIImage imageNamed:@"cap.jpg"]];
        [_elementView addSubview:_capImageView];
    }
    return _elementView;
}




@end














