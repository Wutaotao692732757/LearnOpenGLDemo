//
//  ViewController.m
//  videotoolbox
//
//  Created by wutaotao on 2017/5/18.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) UILabel *mLabel;
@property (nonatomic, strong) AVCaptureSession *mCaptureSession;

@property (nonatomic, strong) AVCaptureDeviceInput *mCaptureDeviceInput;

@property (nonatomic, strong) AVCaptureVideoDataOutput *mCaptureDeviceoutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *mPreviewlayer;

@end

@implementation ViewController{
    int frameID;
    dispatch_queue_t mCaptureQueue;
    dispatch_queue_t mEncodeQueue;
    VTCompressionSessionRef EncodingSession;
    CMFormatDescriptionRef format;
    NSFileHandle *fileHandle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 100)];
    self.mLabel.textColor = [UIColor redColor];
    
    [self.view addSubview:self.mLabel];
    self.mLabel.text = @"测试H264硬编码";
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 20, 100, 100)];
    [button setTitle:@"play" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
 

}
- (void)onClick:(UIButton *)button {
    if (!self.mCaptureSession || !self.mCaptureSession.running) {
        [button setTitle:@"stop" forState:UIControlStateNormal];
        [self startCapture];
        
    }
    else {
        [button setTitle:@"play" forState:UIControlStateNormal];
        [self stopCapture];
        
    }
}

-(void)startCapture{
    self.mCaptureSession = [[AVCaptureSession alloc]init];
    self.mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    mCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    mEncodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device position] == AVCaptureDevicePositionBack) {
            inputCamera = device;
        }
    }
    self.mCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:inputCamera error:nil];
    
    if ([self.mCaptureSession canAddInput:self.mCaptureDeviceInput]) {
        [self.mCaptureSession addInput:self.mCaptureDeviceInput];
    }
    
    self.mCaptureDeviceoutput = [[AVCaptureVideoDataOutput alloc]init];
    [self.mCaptureDeviceoutput setAlwaysDiscardsLateVideoFrames:NO];
    
    [self.mCaptureDeviceoutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.mCaptureDeviceoutput setSampleBufferDelegate:self queue:mCaptureQueue];
    
    if ([self.mCaptureSession canAddOutput:self.mCaptureDeviceoutput]) {
        [self.mCaptureSession addOutput:self.mCaptureDeviceoutput];
    }
    AVCaptureConnection *connection = [self.mCaptureDeviceoutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    self.mPreviewlayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.mCaptureSession];
    [self.mPreviewlayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.mPreviewlayer setFrame:self.view.bounds];
    [self.view.layer addSublayer:self.mPreviewlayer];
    
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"abc.h264"];
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
    [self initVideoToolBox];
    [self.mCaptureSession startRunning];
    
}

-(void)initVideoToolBox{
    
    dispatch_sync(mEncodeQueue, ^{
        frameID = 0;
        int width = 480, height = 640;
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self), &EncodingSession);
        if (status != 0) {
            NSLog(@"H264 : Unable to create a H264 session");
            return ;
        }
        
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
        
        int frameInterval = 10;
        CFNumberRef frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
        
        int fps = 10;
        CFNumberRef fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
        
        int bitRate = width * height * 3 * 4 * 8;
        CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
        
        int bitRateLimit = width * height *3 *4;
        CFNumberRef bitRatelimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRateLimit);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_DataRateLimits, bitRatelimitRef);
        
        VTCompressionSessionPrepareToEncodeFrames(EncodingSession);
  
    });
   
}

-(void)encode:(CMSampleBufferRef)sampleBuffer{
    
//    CVImageBufferRef imagebuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
//    CMTime presentationTimeStamp = CMTimeMake(frameID++, 1000);
//    VTEncodeInfoFlags flags;
//    OSStatus statusCode = VTCompressionSessionEncodeFrame(EncodingSession, imagebuffer, presentationTimeStamp, kCMTimeInvalid, NULL, NULL, &flags);
//    
//    if (statusCode != noErr) {
//        NSLog(@"H264 : VTCompressionSessionEncodeFrame failed with %d ",(int)statusCode);
//        VTCompressionSessionInvalidate(EncodingSession);
//        CFRelease(EncodingSession);
//        EncodingSession = NULL;
//        return ;
//    }
    
    
    
    
    NSLog(@"H264: VTCompressionsession");
}

void didCompressH264(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef samplebuffer){
    
    if (status != 0) {
        return;
    }
    
    if (!CMSampleBufferDataIsReady(samplebuffer)) {
        NSLog(@"didCompressH264 data is not ready");
        return;
    }
    
    ViewController *encoder = (__bridge ViewController *)outputCallbackRefCon;
    
    bool keyframe = !CFDictionaryContainsKey((CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(samplebuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    
    if (keyframe) {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(samplebuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0);
        
        if (statusCode == noErr) {
            
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
            if (statusCode == noErr) {
                NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                if (encoder) {
//                    [encoder ];
                }
                
            }
     
        }
  
    }
    
    
    CMBlockBufferRef databuffer = CMSampleBufferGetDataBuffer(samplebuffer);
    size_t length, totalLength;
    char *datapointer;
    
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(databuffer, 0, &length, &totalLength, &datapointer);
    
    if (statusCodeRet == noErr) {
        
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, datapointer + bufferOffset, AVCCHeaderLength);
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
        
            NSData *data = [[NSData alloc]initWithBytes:(datapointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
            [encoder gotEncodedData:data iskeyFrame:keyframe];
            
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        
        }
     
    }
 
}

-(void)gotSpsPps:(NSData *)sps pps:(NSData *)pps{
    
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1;
    NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
    [fileHandle writeData:byteHeader];
    [fileHandle writeData:sps];
    [fileHandle writeData:byteHeader];
    [fileHandle writeData:pps];
    
    
}

-(void)gotEncodedData:(NSData *)data iskeyFrame:(BOOL)isKeyFrame{
    
    if (fileHandle != NULL) {
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1;
        NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
        [fileHandle writeData:ByteHeader];
        [fileHandle writeData:data];
    }
}

-(void)EndVideoToolBox{
    
    VTCompressionSessionCompleteFrames(EncodingSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(EncodingSession);
    CFRelease(EncodingSession);
    EncodingSession = NULL;
}

-(void)stopCapture{
    [self.mCaptureSession stopRunning];
    [self.mPreviewlayer removeFromSuperlayer];
    [self EndVideoToolBox];
    [fileHandle closeFile];
    fileHandle = NULL;
}


@end
















