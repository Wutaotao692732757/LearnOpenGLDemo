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

@implementation UFVideoDecoder

- (void)decodeWithCodec:(AVCodecContext *)codec packet:(AVPacket)packet {
  
    [self findSPSAndPPSInCodec:codec];
    [self decodePacket:packet];
}

#pragma mark - Private Methods
// 找寻SPS和PPS数据
- (void)findSPSAndPPSInCodec:(AVCodecContext *)codec {
    // 将用不上的字节替换掉，在SPS和PPS前添加开始码
    // 假设extradata数据为 0x01 64 00 0A FF E1 00 19 67 64 00 00...其中67开始为SPS数据
    //  则替换后为0x00 00 00 01 67 64...
    
    // 使用FFMPEG提供的方法。
    // 我一开始以为FFMPEG的这个方法会直接获取到SPS和PPS，谁知道只是替换掉开始码。
    // 要注意的是，这段代码会一直报**Packet header is not contained in global extradata, corrupted stream or invalid MP4/AVCC bitstream**。可是貌似对数据获取没什么影响。我就直接忽略了
    uint8_t *dummy = NULL;
    int dummy_size;
    AVBitStreamFilterContext* bsfc =  av_bitstream_filter_init("h264_mp4toannexb");
    av_bitstream_filter_filter(bsfc, codec, NULL, &dummy, &dummy_size, NULL, 0, 0);
    av_bitstream_filter_close(bsfc);
    
    // 获取SPS和PPS的数据和长度
    int startCodeSPSIndex = 0;
    int startCodePPSIndex = 0;
    uint8_t *extradata = codec->extradata;
    for (int i = 3; i < codec->extradata_size; i++) {
        if (extradata[i] == 0x01 && extradata[i-1] == 0x00 && extradata[i-2] == 0x00 && extradata[i-3] == 0x00) {
            if (startCodeSPSIndex == 0) startCodeSPSIndex = i + 1;
            if (i > startCodeSPSIndex) {
                startCodePPSIndex = i + 1;
                break;
            }
        }
    }
    
    // 这里减4是因为需要减去PPS的开始码的4个字节
    int spsLength = startCodePPSIndex - 4 - startCodeSPSIndex;
    int ppsLength = codec->extradata_size - startCodePPSIndex;
    
    _spsData = [NSData dataWithBytes:&extradata[startCodeSPSIndex] length:spsLength];
    _ppsData = [NSData dataWithBytes:&extradata[startCodePPSIndex] length:ppsLength];
    
    if (_spsData != nil && _ppsData != nil) {
        // Set H.264 parameters
        const uint8_t* parameterSetPointers[2] = { (uint8_t *)[_spsData bytes], (uint8_t *)[_ppsData bytes] };
        const size_t parameterSetSizes[2] = { [_spsData length], [_ppsData length] };
        // 创建CMVideoFormatDesc
        _status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, parameterSetPointers, parameterSetSizes, 4, &_formatDescriptionRef);
        if (_status != noErr) NSLog(@"\n\nFormat Description ERROR: %d", (int)_status);
    }
 
    if (_status == noErr && _decompressionSessionRef == NULL) [self createDecompressionSession];
  
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

// 解析IDR或no-IDR数据
- (void)decodePacket:(AVPacket)packet {
    uint8_t* frame = packet.data;
    int size = packet.size;
    
    int startIndex = 4; // 数据都从第5位开始
    int nalu_type = ((uint8_t)frame[startIndex] & 0x1F);
    // 1为IDR，5为no-IDR
//    if (nalu_type == 1 || nalu_type == 5) {
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
//    }
}

@end
