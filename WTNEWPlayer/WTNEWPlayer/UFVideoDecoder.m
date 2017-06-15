//
//  UFVideoDecoder.m
//  EX_appIOS
//
//  Created by wutaotao on 2017/6/5.
//  Copyright © 2017年 aee. All rights reserved.
//

#import "UFVideoDecoder.h"
#import <VideoToolbox/VideoToolbox.h>
#import <VideoToolbox/VTBase.h>

// 利用FFMPEG的解码器，获取到sps和pps，IDR数据
// SPS和PPS数据在codec中的extradata中
// IDR数据在packet的data中
//- (void)setupVideoDecoder {
//    _pCodecCtx = _pFormatCtx->streams[_videoStream]->codec;
//    
//    while (av_read_frame(_pFormatCtx, &_packet) >= 0) {
//        // Whether is video stream
//        if (_packet.stream_index == _videoStream) {
//            [self.videoDecoder decodeWithCodec:_pCodecCtx packet:_packet];
//        }
//    }
//}
@interface UFVideoDecoder () {
    NSData *_spsData;
    NSData *_ppsData;
    VTDecompressionSessionRef _decompressionSessionRef;
    CMVideoFormatDescriptionRef _formatDescriptionRef;
    OSStatus _status;
}

@end

@implementation UFVideoDecoder{
   
        dispatch_queue_t mDecodeQueue;
        VTDecompressionSessionRef mDecodeSession;
        CMFormatDescriptionRef  mFormatDescription;
        uint8_t *mSPS;
        long mSPSSize;
        uint8_t *mPPS;
        long mPPSSize;
        
        // 输入
        NSInputStream *inputStream;
        uint8_t*       packetBuffer;
        long           packetSize;
        uint8_t*       inputBuffer;
        long           inputSize;
        long           inputMaxSize;
   
}

- (void)decodeWithCodec:(AVCodecContext *)codec packet:(AVPacket)packet {
  
//    [self findSPSAndPPSInCodec:codec];
//    [self decodePacket:packet];
 
    
    [self decodePacketWithSomeThingNew:packet];
    
}


// 创建session
- (void)createDecompressionSession {
    // Make sure to destory the old VTD session
    _decompressionSessionRef = NULL;
    
    // 回调函数
    VTDecompressionOutputCallbackRecord callbackRecord;
    callbackRecord.decompressionOutputCallback = decompressionSessionDecodeFrameCallback;
    // 如果需要在回调函数中调用到self的话
    callbackRecord.decompressionOutputRefCon = (__bridge void*)self;
    
    // pixelBufferAttributes
    NSDictionary *destinationImageBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], (id)kCVPixelBufferOpenGLCompatibilityKey, [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey, nil];
    _status = VTDecompressionSessionCreate(NULL, _formatDescriptionRef, NULL, (__bridge CFDictionaryRef)(destinationImageBufferAttributes), &callbackRecord, &_decompressionSessionRef);
    
    if(_status != noErr) NSLog(@"\t\t VTD ERROR type: %d", (int)_status);
}

// 回调函数
void decompressionSessionDecodeFrameCallback(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef imageBuffer, CMTime presentationTimestamp, CMTime presentationDuration) {
    NSLog(@"进入回调函数");
    UFVideoDecoder *decoder = (__bridge UFVideoDecoder*)decompressionOutputRefCon;
    if (status != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Decompressed error: %@", error);
    } else {
        // 回传图像
        NSLog(@"开始回传图像");
        [decoder.delegate getDecodeImageData:imageBuffer];
    }
}


-(void)decodePacketWithSomeThingNew:(AVPacket)packet{
    
    if (mDecodeQueue==nil) {
        mDecodeQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, DISPATCH_QUEUE_SERIAL);
    }
   
    dispatch_async(mDecodeQueue, ^{
        
        if (packetSize && packetBuffer) {
            packetSize = 0;
            free(packetBuffer);
            packetBuffer = NULL;
        }
        if (inputSize && inputBuffer) {
            inputSize = 0;
            free(inputBuffer);
            inputBuffer = NULL;
        }
        inputSize = packet.size;
        inputBuffer =malloc(inputSize);
        memcpy(inputBuffer, packet.data, inputSize);
        
        long zerocount = 0; NSMutableArray * indexArr = [NSMutableArray array];
        [indexArr removeAllObjects];
        for (int i=0; i<inputSize; ++i) {
            
            if ((inputBuffer[i]&0xFF)==0) {
                
                ++zerocount;
                if (zerocount>=3&&((inputBuffer[i+1]&0xFF)==1)) {
                    NSNumber *index = [NSNumber numberWithInt:i-2];
                    if (i-2==0) {
                        index = [NSNumber numberWithInt:0];
                    }
                    [indexArr addObject:index];
                }
                
            }else{
                zerocount=0;
            }
        }
        
        for (int i=0; i<indexArr.count; i++) {
 
            if (i+1<indexArr.count) {
                NSNumber *beginnum = indexArr[i]; NSNumber *endnum = indexArr[i+1];
                int begin = [beginnum intValue];
                int end = [endnum intValue];
                packetSize = end - begin;
                packetBuffer = malloc(packetSize);
                memcpy(packetBuffer, inputBuffer+begin, end-begin);
            }else{
                NSNumber *lastendnum = indexArr[i];
                int lastend = [lastendnum intValue];
                packetSize = inputSize - lastend;
                packetBuffer = malloc(packetSize);
                memcpy(packetBuffer, inputBuffer+lastend, packetSize);
               
            }
            
                uint32_t nalSize = (uint32_t)(packetSize - 4);
                uint32_t *pNalSize = (uint32_t *)packetBuffer;
                *pNalSize = CFSwapInt32HostToBig(nalSize);
            
            NSData *packetdata = [NSData dataWithBytes:packetBuffer length:packetSize];
            NSLog(@"包内容:%@",packetdata);
            // 在buffer的前面填入代表长度的int
            CVPixelBufferRef pixelBuffer = NULL;
            int nalType = packetBuffer[4] & 0x1F;
            switch (nalType) {
                case 0x05:
                    NSLog(@"Nal type is IDR frame");
                    [self initVideoToolBox];
                    pixelBuffer = [self decode];
                    break;
                case 0x07:
                    NSLog(@"Nal type is SPS");
                    mSPSSize = packetSize - 4;
                    mSPS = malloc(mSPSSize);
                    memcpy(mSPS, packetBuffer + 4, mSPSSize);
                    break;
                case 0x08:
                    NSLog(@"Nal type is PPS");
                    mPPSSize = packetSize - 4;
                    mPPS = malloc(mPPSSize);
                    memcpy(mPPS, packetBuffer + 4, mPPSSize);
                    break;
                default:
                    NSLog(@"Nal type is B/P frame");
                    pixelBuffer = [self decode];
                    break;
            }
         
            if(pixelBuffer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                 [self.lyOpenGLView displayPixelBuffer:pixelBuffer];
                    
                    NSLog(@"开始绘制buffer数据");
                    
                    CVPixelBufferRelease(pixelBuffer);
                });
            }
            NSLog(@"Read Nalu size %ld", packetSize);
            
            
        }
       av_packet_unref(&packet);
    });
   
}
void didDecompress(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}
- (void)initVideoToolBox {
    if (!mDecodeSession) {
        const uint8_t* parameterSetPointers[2] = {mSPS, mPPS};
        const size_t parameterSetSizes[2] = {mSPSSize, mPPSSize};
        OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                              2, //param count
                                                                              parameterSetPointers,
                                                                              parameterSetSizes,
                                                                              4, //nal start code size
                                                                              &mFormatDescription);
        if(status == noErr) {
            CFDictionaryRef attrs = NULL;
            const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
            //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
            //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
            //      kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
            //      kCVPixelFormatType_420YpCbCr8PlanarFullRange
            uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
            const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
            attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            
            VTDecompressionOutputCallbackRecord callBackRecord;
            callBackRecord.decompressionOutputCallback = didDecompress;
            callBackRecord.decompressionOutputRefCon = NULL;
            
            status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                                  mFormatDescription,
                                                  NULL, attrs,
                                                  &callBackRecord,
                                                  &mDecodeSession);
            CFRelease(attrs);
        } else {
            NSLog(@"IOS8VT: reset decoder session failed status=%d", status);
        }
        
        
    }
}


-(CVPixelBufferRef)decode {
    
    CVPixelBufferRef outputPixelBuffer = NULL;
    if (mDecodeSession) {
        CMBlockBufferRef blockBuffer = NULL;
        OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                              (void*)packetBuffer,     packetSize,
                                                              kCFAllocatorNull,
                                                              NULL, 0, packetSize,
                                                              0, &blockBuffer);
        if(status == kCMBlockBufferNoErr) {
            CMSampleBufferRef sampleBuffer = NULL;
            const size_t sampleSizeArray[] = {packetSize};
            status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                               blockBuffer,
                                               mFormatDescription,
                                               1, 0, NULL, 1, sampleSizeArray,
                                               &sampleBuffer);
            if (status == kCMBlockBufferNoErr && sampleBuffer) {
                VTDecodeFrameFlags flags = 0;
                VTDecodeInfoFlags flagOut = 0;
                // 默认是同步操作。
                // 调用didDecompress，返回后再回调
                OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(mDecodeSession, sampleBuffer,  flags,  &outputPixelBuffer,      &flagOut);
                if(decodeStatus == kVTInvalidSessionErr)
                {
                    NSLog(@"IOS8VT: Invalid session, reset decoder session");
                    [self resetH264Decoder];
                }
                if(decodeStatus == kVTInvalidSessionErr) {
                    NSLog(@"IOS8VT: Invalid session, reset decoder session");
                } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                    NSLog(@"IOS8VT: decode failed status=%d(Bad data)", decodeStatus);
                } else if(decodeStatus != noErr) {
                    NSLog(@"IOS8VT: decode failed status=%d", decodeStatus);
                }
                
                CFRelease(sampleBuffer);
            }
            CFRelease(blockBuffer);
        }
    }
    
    return outputPixelBuffer;
}

- (void)resetH264Decoder
{
    if(mDecodeSession) {
        VTDecompressionSessionInvalidate(mDecodeSession);
        CFRelease(mDecodeSession);
        mDecodeSession = NULL;
    }
    CFDictionaryRef attrs = NULL;
    const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
    //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
    //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
    uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
    attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    VTDecompressionOutputCallbackRecord callBackRecord;
    callBackRecord.decompressionOutputCallback = didDecompress;
    callBackRecord.decompressionOutputRefCon = NULL;
    if(VTDecompressionSessionCanAcceptFormatDescription(mDecodeSession, mFormatDescription))
    {
        NSLog(@"yes");
    }
    
    OSStatus status = VTDecompressionSessionCreate(kCFAllocatorSystemDefault,
                                                   mFormatDescription,
                                                   NULL, attrs,
                                                   &callBackRecord,
                                                   &mDecodeSession);
    CFRelease(attrs);
}

// 解析IDR或no-IDR数据
- (void)decodePacket:(AVPacket)packet {
    uint8_t* frame = packet.data;
    int size = packet.size;
    
    NSData *data = [NSData dataWithBytes:frame length:size];
    NSLog(@"%@",data);
//    int startIndex = 4; // 数据都从第5位开始
//    int nalu_type = ((uint8_t)frame[startIndex] & 0x1F);//
    int nalu_type;
    if(( 0 == *(frame+0) ) &&
       
       ( 0 == *(frame+1) ) &&
       
       ( 0 == *(frame+2) ) &&
       
       ( 1 == *(frame+3) ) )
        
    {
        nalu_type = (0x01f&(*(frame+4))); //低5位判断是否为
    }
    
    // 1为IDR，5为no-IDR   //  1 || 5    || nalu_type == 7
    if (nalu_type == 5 || nalu_type == 6 ) {
        // 创建CMBlockBuffer
        CMBlockBufferRef blockBufferRef = NULL;
        _status = CMBlockBufferCreateWithMemoryBlock(NULL, frame, size, kCFAllocatorNull, NULL, 0, size, 0, &blockBufferRef);
        
        // 移除掉前面4个字节的数据
        int reomveHeaderSize = size - 4;
        const uint8_t sourceBytes[] = {(uint8_t)(reomveHeaderSize >> 24), (uint8_t)(reomveHeaderSize >> 16), (uint8_t)(reomveHeaderSize >> 8), (uint8_t)reomveHeaderSize};
        _status = CMBlockBufferReplaceDataBytes(sourceBytes, blockBufferRef, 0, 4);
        
        // CMSampleBuffer
        CMSampleBufferRef sbRef = NULL;
        //        int32_t timeSpan = 90000;
        //        CMSampleTimingInfo timingInfo;
        //        timingInfo.presentationTimeStamp = CMTimeMake(0, timeSpan);
        //        timingInfo.duration =  CMTimeMake(3000, timeSpan);
        //        timingInfo.decodeTimeStamp = kCMTimeInvalid;
        const size_t sampleSizeArray[] = {size};
        _status = CMSampleBufferCreate(kCFAllocatorDefault, blockBufferRef, true, NULL, NULL, _formatDescriptionRef, 1, 0, NULL, 1, sampleSizeArray, &sbRef);
        
        // 解析
        VTDecodeFrameFlags flags = kVTDecodeFrame_EnableAsynchronousDecompression;
        VTDecodeInfoFlags flagOut;
        _status = VTDecompressionSessionDecodeFrame(_decompressionSessionRef, sbRef, flags, &sbRef, &flagOut);
        CFRelease(sbRef);
        
        
    }
}

@end
