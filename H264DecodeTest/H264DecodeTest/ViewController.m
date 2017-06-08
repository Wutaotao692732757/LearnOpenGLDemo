//
//  ViewController.m
//  H264DecodeTest
//
//  Created by wutaotao on 2017/6/7.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import "VideoFileParser.h"
#import "AAPLEAGLLayer.h"
#import <VideoToolbox/VideoToolbox.h>

@interface ViewController ()
{
    uint8_t * _sps;
    NSInteger _spsSize;
    uint8_t * _pps;
    NSInteger _ppsSize;
    VTDecompressionSessionRef _deocderSession;
    CMVideoFormatDescriptionRef _decoderFormatDescription;
    AAPLEAGLLayer *_glLayer;
}
@end

static void didDecompress(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer,CMTime presentationTimeStamp, CMTime presentationDuration){
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}


@implementation ViewController

-(BOOL)initH264Decoder{
    if (_deocderSession) {
        return YES;
    }
    const uint8_t * const parameterSetPointers[2] = {_sps,_pps};
    const size_t parameterSetSizes[2] = {_spsSize,_ppsSize};
    
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, parameterSetPointers, parameterSetSizes, 4, &_decoderFormatDescription);
    
    if (status == noErr) {
        CFDictionaryRef attrs = NULL;
        const void *keys[] = {kCVPixelBufferPixelFormatTypeKey};
        
        uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        const void *values[] = {CFNumberCreate(NULL, kCFNumberSInt32Type, &v)};
        attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = NULL;
        
        status = VTDecompressionSessionCreate(kCFAllocatorDefault, _decoderFormatDescription, NULL, attrs, &callBackRecord, &_deocderSession);
        CFRelease(attrs);
        
    }else{
        NSLog(@"IOS8VT: reset decoder session failed status=%d",status);
    }
    return YES;
}

-(void)clearH264Deocder{
    if (_deocderSession) {
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = NULL;
    }
    if (_decoderFormatDescription) {
        CFRelease(_decoderFormatDescription);
        _decoderFormatDescription = NULL;
    }
    
    free(_sps);
    free(_pps);
    _spsSize = _ppsSize = 0;
    
}

-(CVPixelBufferRef)decode:(VideoPacket *)vp{
    CVPixelBufferRef outputPixelBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, (void*)vp.buffer, vp.size, kCFAllocatorNull, NULL, 0, vp.size, 0, &blockBuffer);
    
    if (status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {vp.size};
        status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, _decoderFormatDescription, 1, 0, NULL, 1, sampleSizeArray, &sampleBuffer);
        if (status == kCMBlockBufferNoErr && sampleBuffer) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_deocderSession, sampleBuffer, flags, &outputPixelBuffer, &flagOut);
            if (decodeStatus == kVTInvalidSessionErr) {
                NSLog(@"IOS8VT: Invalid session , reset decoder session");
            }else if (decodeStatus == kVTVideoDecoderBadDataErr){
                NSLog(@"IOS8VT: decode failed status = %d(Bad data)",decodeStatus);
            }else if (decodeStatus != noErr){
                NSLog(@"IOS8VT: decode failed status = %d",decodeStatus);
            }
         
            CFRelease(sampleBuffer);
        }
        
        CFRelease(blockBuffer);
        
    }
    
    return outputPixelBuffer;
}

-(void)decodeFile:(NSString *)fileName fileExt:(NSString *)fileExt{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt];
    VideoFileParser *parser = [VideoFileParser alloc];
    [parser open:path];
    VideoPacket *vp = nil;
    
    while (true) {
        vp = [parser nextPacket];
        if (vp == nil) {
            break;
        }
        uint32_t nalSize = (uint32_t)(vp.size - 4);
        uint8_t *pNalSize = (uint8_t*)(&nalSize);
        vp.buffer[0] = *(pNalSize + 3);
        vp.buffer[1] = *(pNalSize + 2);
        vp.buffer[2] = *(pNalSize + 1);
        vp.buffer[3] = *(pNalSize);
        
        CVPixelBufferRef pixelBuffer = NULL;
        int nalType = vp.buffer[4] & 0x1F;
        switch (nalType) {
            case 0x05:
                NSLog(@"Nal type is IDR frame");
                if ([self initH264Decoder]) {
                    pixelBuffer = [self decode:vp];
                }
                break;
             case 0x07:
                NSLog(@"Nal type is SPS");
                _spsSize = vp.size - 4;
                _sps = malloc(_spsSize);
                memcpy(_sps, vp.buffer + 4, _spsSize);
                break;
             case 0x08:
                NSLog(@"Nal type is PPS");
                _ppsSize = vp.size - 4;
                _pps = malloc(_ppsSize);
                memcpy(_pps, vp.buffer + 4, _ppsSize);
                break;
            default:
                NSLog(@"Nal type is B/P frame");
                pixelBuffer = [self decode:vp];
                break;
        }
        if (pixelBuffer) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                _glLayer.pixelBuffer = pixelBuffer;
            });
            
            CVPixelBufferRelease(pixelBuffer);
            
        }
        NSLog(@"Read Nalu size %ld",vp.size);
    }
    [parser close];
    
}


- (IBAction)playVideo:(id)sender {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self decodeFile:@"mtv" fileExt:@"h264"];
    });
    
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    _glLayer = [[AAPLEAGLLayer alloc]initWithFrame:self.view.bounds];
    [self.view.layer addSublayer:_glLayer];
    
}




@end
