//
//  CameraTool.m
//  AEE
//
//  Created by aee on 16/6/1.
//  Copyright (c) 2016年 LIU. All rights reserved.
//

#import "CameraTool.h"
#import "ModelData.h"
#import "CameraInfo.h"
#import "CameraInfoTwelve.h"
#import "AsyncSocket.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#define TOKEN     @"token"
#define MSGID     @"msg_id"
#define PARAM     @"param"
#define OFFSET    @"offset"
#define SIZE      @"param_size"
#define TYPE      @"type"
#define RVAL      @"rval"
#define DCIMPATH @"/tmp/fuse_d/DCIM/100MEDIA"
#define DCIMPATH_Twelve @"/tmp/SD0/DCIM/100MEDIA"
#define FILEPATH  @"/tmp/fuse_d/MISC"
#define WIFIPATH  @"/tmp/fuse_d/MISC/wifi.conf"

#define AEE_START_SESSION        257   //开始会话
#define AEE_STOP_SESSION         258
#define AEE_RESETVF              259   //重置VF状态
#define AEE_STOPVF               260   // STOP VF 
#define AEE_OPEN_TCP             261    //打开TCP端口
#define AEE_START_RECORD         513   //开始录像
#define AEE_STOP_RECORD          514
#define AEE_GET_RECORDTIME       515    //获取当前录像时间
#define AEE_TAKE_PHOTO           769    //拍照
#define AEE_TAKE_LAPSEPHOTO      2062   //连拍    ------- ------- ------- 暂无用
#define AEE_STOP_LAPSEPHOTO      770    //取消连拍
#define AEE_BURNIN_FW            8      //上传成功后硬件更新
#define AEE_GET_SINGLE_OPTION    9      //得到某个属性状态
#define AEE_START_FormatSD       4      //格式化
#define AEE_GET_ALL_OPTIONS      3      //得到所有属性infomation
#define AEE_SET_SETTING          2     // 设置某项参数
#define AEE_CROSS_CONTROL        7     //交叉控制相机进行的响应事件
#define AEE_DELETE_FILE          1281   //删除文件
#define AEE_ZOOM_IN              2330   //缩小
#define AEE_ZOOM_OUT             2331   //放大
#define AEE_GET_PLIST            1282   //获取回放所有的文件信息
#define AEE_CHECK_PATH           1283   //查找路径"/tmp/fuse_d/MISC"是否存在
#define AEE_GET_WIFI_CONFIG      1285   //获取WIFI的配置文件写入相机生成接口数据
#define AEE_RENEW_WIFI_CONFIG    1286  //上传文件修改wifi配置信息
#define AEE_WIFI_RESTART         1537  // 重启WiFi
#define AEE_SET_WIFI             2049  //A12平台修改wifi


#define A7_VERSION    @[@"AEE S61",@"AEE S41B",@"AEE S41C",@"AEE YT32",@"AEE S90C"]
#define A12_VERSION   @[@"AEE S77",@"AEE S90A",@"AEE S90B",@"AEE S96",@"AEE LYFE TITAN",@"AEE LYFE S72",@"AEE Lyfe Titan",@"AEE OL12S",@"Extreme Icon-4",@"Extreme Icon-1",@"KONDOR EXTICON-4",@"KONDOR EXTICON-1",@"AEE S90R"]
@interface CameraTool ()<NSStreamDelegate,AsyncSocketDelegate>

{
    AsyncSocket *asyncSocket;
    NSMutableData *appendData;
    NSMutableData *writeData2;
    NSMutableData *writeData3;
}


@property (assign,nonatomic)int tokenValue;

@end


@implementation CameraTool

static id tool = nil;
CameraInfo *cameraInfo = nil;
CameraInfoTwelve *twelve = nil;

+ (id)shareTool{
    if (!tool) {
        @synchronized(self){
            if (!tool) {
                tool = [[self alloc]init]; 
            }
            return tool;
        }
    }
    return tool;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    if (!tool) {
        
        @synchronized(self){
            if (!tool) {
                tool = [super allocWithZone:zone];
            }
        }
    }
    return tool;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        cameraInfo = [[CameraInfo alloc]init];
        twelve = [[CameraInfoTwelve alloc]init];
        appendData = [NSMutableData data];
    }
    return self;
}
- (void)sendMessageIDToCarema:(NSDictionary *)dic{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    //用于检测是否存在斜线并进行优化
    NSString *checkSlant = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];//路径下回产生字符“\”
    checkSlant = [checkSlant stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSData *d = [checkSlant dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"sendMSG:---%@",[[NSString alloc]initWithData:d encoding:NSUTF8StringEncoding]);
    [asyncSocket writeData:d withTimeout:-1 tag:0];
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)connectingOperate{
    
//    if (asyncSocket) {
//        [asyncSocket disconnect];
//        asyncSocket = nil;
//    }
    
    if (!asyncSocket)
    {
        asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        NSError *err = nil;
        
        if(![asyncSocket connectToHost:@"192.168.42.1" onPort:7878 withTimeout:10 error:&err])
        {
            NSLog(@"Error: %@", err);
        }
        NSLog(@"first asyncSocket connected");
    }
    NSDictionary *dic = @{TOKEN:@0,MSGID:[NSNumber numberWithInt:AEE_START_SESSION]};
    [self sendMessageIDToCarema:dic];
}

- (void)disconnectOperate{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_STOP_SESSION]};
    [self sendMessageIDToCarema:dic];
}
- (void)recordOperate{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_START_RECORD]};
    [self sendMessageIDToCarema:dic];
}
- (void)recordStopOperate{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_STOP_RECORD]};
    [self sendMessageIDToCarema:dic];
}
- (void)shutterOperate{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_TAKE_PHOTO]};
    [self sendMessageIDToCarema:dic];
}
- (void)deleteFiles:(NSString *)str{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_DELETE_FILE],PARAM:str};
    [self sendMessageIDToCarema:dic];
}
- (void)stopVF{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_STOPVF]};
    [self sendMessageIDToCarema:dic];
}
- (void)resetVF{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_RESETVF]};
    [self sendMessageIDToCarema:dic];
}
- (void)stopLastPhoto{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_STOP_LAPSEPHOTO]};
    [self sendMessageIDToCarema:dic];
}
- (void)getAllOptions{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_GET_ALL_OPTIONS]};
    [self sendMessageIDToCarema:dic];
}
- (void)getRecordingTime{
    
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithUnsignedInteger:AEE_GET_RECORDTIME]};
    [self sendMessageIDToCarema:dic];
    
}
- (void)setOptionsMode:(NSString *)status Type:(NSString*)type{
    if (!status) return;
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                          MSGID:[NSNumber numberWithInt:AEE_SET_SETTING],
                          PARAM:status,
                          TYPE:type};
    [self sendMessageIDToCarema:dic];
}
- (void)setWiFiInfoWithNewNameAndPassword:(NSString *)info{
    
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                          MSGID:[NSNumber numberWithInt:AEE_SET_WIFI],
                          PARAM:info};
    [self sendMessageIDToCarema:dic];
    
    
}
- (void)getSingleWithOption:(NSString *)option{
    if (!option) return;
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                          MSGID:[NSNumber numberWithInt:AEE_GET_SINGLE_OPTION],
                          PARAM:option};
    [self sendMessageIDToCarema:dic];
}
- (void)zoomIn{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_ZOOM_IN]};
    [self sendMessageIDToCarema:dic];
}
- (void)zoomOut{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_ZOOM_OUT]};
    [self sendMessageIDToCarema:dic];
}
- (void)traversePath:(NSString *)path{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_CHECK_PATH],PARAM:path};
    
    [self sendMessageIDToCarema:dic];
}
- (void)getWiFiConfigFile{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                          MSGID:[NSNumber numberWithInt:AEE_GET_WIFI_CONFIG],
                          PARAM:@"wifi.conf",
                          @"offset":@0,
                          @"fetch_size":@0
                          };
    
    [self sendMessageIDToCarema:dic];
}
- (void)refreshWifiConfigFile:(int)size md5:(NSString*)md5
{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                          MSGID:[NSNumber numberWithInt:AEE_RENEW_WIFI_CONFIG],
                          PARAM:WIFIPATH,
                          @"size":[NSNumber numberWithInt:size],
                          @"md5sum":md5,
                          @"offset":@0
                          };
    
    [self sendMessageIDToCarema:dic];
}
- (void)restartWifi{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_WIFI_RESTART]};
    [self sendMessageIDToCarema:dic];
}
- (void)logoInPutFileTCP{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                          MSGID:[NSNumber numberWithInt:AEE_OPEN_TCP],
                         // PARAM:[self ipAddress],
                          TYPE:@"TCP"};
    
    [self sendMessageIDToCarema:dic];
    
}
- (void)updateFileWithPutFile{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_BURNIN_FW]};
    [self sendMessageIDToCarema:dic];
}
- (void)putfileBin:(int)size md5:(NSString*)md5{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                          MSGID:[NSNumber numberWithInt:AEE_RENEW_WIFI_CONFIG],
                          PARAM:@"firmware.bin",
                          @"size":[NSNumber numberWithInt:size],
                          @"md5sum":md5,
                          @"offset":@0
                          };
    
    [self sendMessageIDToCarema:dic];
    
}
- (void)readDCIM_Path
{
    NSString *path = self.isATwelve? DCIMPATH_Twelve:DCIMPATH;
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_CHECK_PATH], PARAM:path};
    
    [self sendMessageIDToCarema:dic];
}
- (void)getFilePlist
{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:AEE_GET_PLIST]};
    
    [self sendMessageIDToCarema:dic];
}
- (void)formatSDCard{
    NSDictionary *dic;
    if (_isATwelve) {
        dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                MSGID:[NSNumber numberWithInt:AEE_START_FormatSD],
                PARAM: @"c"};
    }else{
        dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],
                MSGID:[NSNumber numberWithInt:AEE_START_FormatSD]};
    }
    [self sendMessageIDToCarema:dic];
}
- (void)initDefaultSetting{
    NSString  *defaultStr = self.isATwelve? @"on":@"set_default_yes";
    [[CameraTool shareTool] setOptionsMode:defaultStr Type:@"set_default"];
}
//不执行任何操作，发送数据  为  0
- (void)setNoAction{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"0"};
    [self sendMessageIDToCarema:dic];
}
- (void)setYawDirectionWithLeft{
     NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"1"};
    [self sendMessageIDToCarema:dic];
}    //手持云台 偏航Yaw向左转动
- (void)setYawDirectionWithRight{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"2"};
    [self sendMessageIDToCarema:dic];

}   //手持云台 偏航Yaw向右转动
- (void)setPitchDirectionWithUp{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"4"};
    [self sendMessageIDToCarema:dic];
}    //手持云台 俯仰Pitch向上转动
- (void)setPitchDirectionWithDown{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"8"};
    [self sendMessageIDToCarema:dic];
}  //手持云台 俯仰Pitch向下转动
- (void)setHandleRestart{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"16"};
    [self sendMessageIDToCarema:dic];
}         //手持云台 归中模式
- (void)setHandleInputAutoPhoto{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"32"};
    [self sendMessageIDToCarema:dic];
}    //手持云台 自拍模式
- (void)setHandleFollowMe{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"64"};
    [self sendMessageIDToCarema:dic];
}
- (void)setHandleLockMode{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x702], PARAM:@"48"};
    [self sendMessageIDToCarema:dic];
}       //手持云台 锁定模式
- (void)setRollDirectionWithUp:(int)data{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x703], PARAM:[NSString stringWithFormat:@"%d",data+64]};
    [self sendMessageIDToCarema:dic];
}    //手持云台 横滚roll向上滚动
- (void)setRollDirectionWithDown:(int)data{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x703], PARAM:[NSString stringWithFormat:@"%d",data+128]};
    [self sendMessageIDToCarema:dic];
}    //手持云台 横滚roll向下滚动
- (void)setSaveInfo:(int)data{
    NSDictionary *dic = @{TOKEN:[NSNumber numberWithInt:self.tokenValue],MSGID:[NSNumber numberWithInt:0x703], PARAM:[NSString stringWithFormat:@"%d",data+192]};
    [self sendMessageIDToCarema:dic];
}    //手持云台 横滚roll保存校准数据

#pragma  - mark - NSStreamDelegate
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //NSLog(@"data: %@",data);
    NSString *backStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"backStr:%@",backStr);
    NSDictionary *readDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    //返回数据eg.{ "msg_id": 7, "type": "put_file_complete" ,"param":2043,"md5sum":"d229c3730158c40aa272d1d8424bab4b"},因此没有"rval" = 0的信息，需要单独进行处理。
    if ([backStr rangeOfString:@"put_file_complete"].location != NSNotFound&&[backStr rangeOfString:@"md5sum"].location != NSNotFound) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"restartWifi" object:self userInfo:readDic];
        return;
    }
    [asyncSocket readDataWithTimeout:-1 tag:0];
    // 获取一次不能截取的数据，然后进行追加
    if (readDic == nil) {
        [appendData appendData:data];
        readDic = [NSJSONSerialization JSONObjectWithData:appendData options:0 error:nil];
        if (readDic) {
            appendData.length = 0;
        }else{
            return;
        }
    }
    
 

    //判断"rval" = 0，如果不等于0将不进行指令响应
     int msgInt = [readDic[@"msg_id"] intValue];
     if (![readDic[RVAL] isEqualToNumber:@0]) {
        switch (msgInt) {   //这里为什么进行一次单独的设置
            case AEE_SET_SETTING:
                [[NSNotificationCenter defaultCenter]postNotificationName:@"setSingleOptions" object:readDic];
                break;
            case AEE_DELETE_FILE:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleFileCompletion" object:readDic[RVAL]];
                break;
            case AEE_CHECK_PATH:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"requestreadDCIM_PathSuccess" object:nil];
                break;
            case AEE_GET_PLIST:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"readPlistSuccess" object:nil];
                break;
            case AEE_TAKE_PHOTO:
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getPhotoStatus" object:readDic[RVAL]];
                break;
            default:
                break;
        }
        return;
    }
    
    //if (![readDic[RVAL] isEqualToNumber:@0])return;
    
    switch (msgInt) {
        case AEE_START_SESSION:
            [self operateStartSession:readDic];
            break;
        case AEE_GET_ALL_OPTIONS:
            [self operateAllOptions:readDic];
            break;
        case AEE_GET_SINGLE_OPTION:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"getSingleOptions" object:readDic];
            break;
        case AEE_GET_RECORDTIME:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"getCurrentRecordTime" object:readDic];
            break;
        case AEE_SET_SETTING:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"setSingleOptions" object:readDic];
            break;
        case AEE_CHECK_PATH:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"requestreadDCIM_PathSuccess" object:readDic];
            break;
            case AEE_GET_PLIST:
        [[NSNotificationCenter defaultCenter] postNotificationName:@"readPlistSuccess" object:readDic];
            break;
        case AEE_GET_WIFI_CONFIG:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"beginReadConfigWiFi" object:nil];
            break;
        case AEE_RENEW_WIFI_CONFIG:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"writeWiFiConfigSuccess" object:nil];
            break;
        case AEE_START_FormatSD:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"formatSDCardCompletion" object:nil];
            break;
        case AEE_CROSS_CONTROL:
            [self crossControlCameraBackDataNotices:readDic];////交叉控制相机进行的响应事件
            break;
//            deleFileCompletion
        case AEE_DELETE_FILE:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleFileCompletion" object:nil];
            break;
        case AEE_TAKE_PHOTO:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"getPhotoStatus" object:nil];
            break;
            default:
            break;
    }
    if (self.isHandleControl && [backStr rangeOfString:@"z09"].location != NSNotFound) {
       // backStr:{"rval":0,"msg_id":769,"mode":2}
        switch (msgInt) {
            case AEE_START_RECORD:
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getRecordStart" object:nil];
                break;
            case AEE_STOP_RECORD:
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getRecordComplete" object:nil];
                break;
            case AEE_TAKE_PHOTO:
                if ([readDic[@"mode"] isEqualToNumber:@2]) {
                    NSLog(@"-----%@",backStr);
                }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getPhotoStatus" object:nil];
                }
                break;
            case AEE_STOP_LAPSEPHOTO:
                [[NSNotificationCenter defaultCenter]postNotificationName:@"getCancelLapsephoto" object:nil];
                break;
                
            default:
                break;
        }
   
    }
    
    if (msgInt == 3&&_getRefreshData) {
        self.getRefreshData(readDic);
    }
    
}
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
      //NSLog(@"..............");
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
      return YES;
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"onSocketDidDisconnect:%p", sock);
    self.isConnecting = NO;
    if (asyncSocket)
    {
        [asyncSocket disconnect];
         asyncSocket = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SocketDidDisconnect" object:nil];
    }
}

#pragma  - mark -  cameraReplyAction
- (void)operateStartSession:(NSDictionary *)dic{
    //    if ([backStr rangeOfString:@"\"rval\": 0, \"msg_id\": 257"].location != NSNotFound) {
    //        self.tokenValue = [[[backStr componentsSeparatedByString:@":"][3] stringByReplacingOccurrencesOfString:@"}" withString:@""] intValue];
    //    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"socketConnectedSuccess" object:nil];
    });
    self.isConnecting = YES;
    self.tokenValue = [dic[PARAM] intValue];
    [self getAllOptions];//这个是提前获取DV型号
    
}
- (void)operateAllOptions:(NSDictionary *)dic{
    NSData *overallData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
//    NSString *showCurrentOverall = [[NSString alloc]initWithData:overallData encoding:NSUTF8StringEncoding];

    
    //得到DV型号
//    NSString *dv_infoA = [showCurrentOverall componentsSeparatedByString:@"get_dv_info\":"][1];
//    NSString *dv_infoB = [dv_infoA componentsSeparatedByString:@"\""][1];
//    NSArray *dv_moduleArr = [[dv_infoB componentsSeparatedByString:@" Ver"][0] componentsSeparatedByString:@" "];
//    NSMutableString *dv_module = [NSMutableString string];
//    for (NSString *str in dv_moduleArr) {
//        if ([str isEqualToString:dv_moduleArr[0]]) {
//            [dv_module appendFormat:@"%@",str];
//        }else if (str.length>0) {
//            [dv_module appendFormat:@" %@",str];
//        }
//    }
 //if([A12_VERSION containsObject:dv_module])
    
    //计算param的值
    NSData *paramData = [NSJSONSerialization dataWithJSONObject:dic[PARAM] options:0 error:nil];
    NSString *paramStr = [[NSString alloc]initWithData:paramData encoding:NSUTF8StringEncoding];
    paramStr = [[paramStr stringByReplacingOccurrencesOfString:@"}" withString:@""]stringByReplacingOccurrencesOfString:@"{" withString:@""];
    paramStr = [[paramStr stringByReplacingOccurrencesOfString:@"[" withString:@"{"]stringByReplacingOccurrencesOfString:@"]" withString:@"}"];
    NSDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:[paramStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    // NSLog(@"paramStr:%@",paramStr);
//    if ([showCurrentOverall rangeOfString:@"get_photo_dzoom"].location != NSNotFound &&[showCurrentOverall rangeOfString:@"get_dual_streams"].location != NSNotFound) {
//        _isATwelve = NO;
//        [cameraInfo setValuesForKeysWithDictionary:paramDic];
//        [self addModelDataWithParameterValue];
//    }else{
        _isATwelve = YES;
        [twelve setValuesForKeysWithDictionary:paramDic];
        [self addModelDataWithParameterCameraTwelve];
//    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"GetAllCameraInfo" object:twelve];
}

-(void)addModelDataWithParameterValue{
    ModelData *model = [ModelData shareData];
    //按钮
    model.video_quality     = cameraInfo.video_quality;
    model.video_stamp       = cameraInfo.video_stamp;
    model.photo_stamp       = cameraInfo.photo_stamp;
    model.video_loop_back   = cameraInfo.video_loop_back;
    //video
    model.video_resolution  = cameraInfo.video_resolution;
    model.video_fov         = cameraInfo.video_fov;
    //photo
    model.photo_size        = cameraInfo.photo_size;
    model.photo_shot_mode   = cameraInfo.photo_shot_mode;
    model.photo_tlm         = cameraInfo.photo_tlm;
    //param
    model.key_tone          = cameraInfo.key_tone;
    model.setup_selflamp    = cameraInfo.setup_selflamp;
    model.setup_osd         = cameraInfo.setup_osd;
    model.video_standard    = cameraInfo.video_standard;
    model.language          = cameraInfo.language;
    model.camera_clock      = cameraInfo.camera_clock;
    model.get_dv_info       = cameraInfo.get_dv_info;
    model.video_flip_rotate = cameraInfo.video_flip_rotate;
    
    model.get_dv_fs         = cameraInfo.get_dv_fs;
    model.get_dv_bat        = cameraInfo.get_dv_bat;
    model.video_time        = cameraInfo.video_time;
    
    NSArray *dv_moduleArr = [[model.get_dv_info componentsSeparatedByString:@" Ver"][0] componentsSeparatedByString:@" "];
    NSMutableString *dv_module = [NSMutableString string];
    for (NSString *str in dv_moduleArr) {
        if ([str isEqualToString:dv_moduleArr[0]]) {
            [dv_module appendFormat:@"%@",str];
        }else if (str.length>0) {
            [dv_module appendFormat:@" %@",str];
        }
    }
    model.moudle = (NSString*)dv_module;
    model.versions = [NSString stringWithFormat:@"Ver:%@",[[model.get_dv_info componentsSeparatedByString:@"Ver:"]lastObject]];
    
    
}
- (void)addModelDataWithParameterCameraTwelve{
    ModelData *model = [ModelData shareData];
    //按钮
    model.video_quality     = twelve.video_quality;
    model.video_stamp       = twelve.video_stamp;
    model.photo_stamp       = twelve.photo_stamp;
    model.video_loop_back   = twelve.video_loop_back;
    //video
    model.video_resolution  = twelve.video_resolution;
    model.video_fov         = twelve.video_fov;
    //photo
    model.photo_size        = twelve.photo_size;
    model.photo_shot_mode   = twelve.photo_shot_mode;
    model.photo_tlm         = twelve.photo_tlm;
    //param
    model.key_tone          = twelve.key_tone;
    model.setup_selflamp    = twelve.setup_selflamp;
    model.video_standard    = twelve.video_standard;
    model.language          = twelve.language;
    model.camera_clock      = twelve.camera_clock;
    model.get_dv_info       = twelve.get_dv_info;
    model.video_flip_rotate = twelve.video_flip_rotate;
    
    model.get_dv_fs         = twelve.get_dv_fs;
    model.get_dv_bat        = twelve.get_dv_bat;
    model.video_time        = twelve.video_time;
    
    NSArray *dv_moduleArr = [[model.get_dv_info componentsSeparatedByString:@" Ver"][0] componentsSeparatedByString:@" "];
    NSMutableString *dv_module = [NSMutableString string];
    for (NSString *str in dv_moduleArr) {
        if ([str isEqualToString:dv_moduleArr[0]]) {
            [dv_module appendFormat:@"%@",str];
        }else if (str.length>0) {
            [dv_module appendFormat:@" %@",str];
        }
    }
    model.moudle = (NSString*)dv_module;
    model.versions = [NSString stringWithFormat:@"Ver:%@",[[model.get_dv_info componentsSeparatedByString:@"Ver:"]lastObject]];
    NSLog(@"%@----%@",model.moudle,model.versions);
}
#pragma   mark       cross_Control
// 交叉控制socket响应，APP进行监听事件
- (void)crossControlCameraBackDataNotices:(NSDictionary *)replyDic{
    static  BOOL isSnap = NO;
    if ([replyDic[@"type"]isEqualToString:@"SNAP2_pressed"]||[replyDic[@"type"]isEqualToString:@"MENU_pressed"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Record_pressedMENU" object:self userInfo:replyDic];
        isSnap = YES;
        return;
    }
    if([replyDic[@"type"]isEqualToString:@"MODE_pressed"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MODE_pressed" object:nil];
        return;
        
    }
    if ([replyDic[@"type"]isEqualToString:@"RECORD_pressed"]) {
        if (isSnap) {
            isSnap = NO;
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Contorl_StartRecord" object:nil];
        return;
    }
    
    if ([replyDic[@"type"]isEqualToString:@"start_video_record"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Contorl_StartRecord" object:nil];
        return;
    }
    if ([replyDic[@"type"]isEqualToString:@"video_record_complete"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Contorl_StopRecord" object:nil];
        return;
    }
    if ([replyDic[@"type"]isEqualToString:@"SPI_RECORD_pressed"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Contorl_StartRecord" object:nil];
        return;
    }
    if ([replyDic[@"type"]isEqualToString:@"SPI_STOP_pressed"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Contorl_StopRecord" object:nil];
        return;
    }
    if ([replyDic[@"type"]isEqualToString:@"STOP_pressed"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Contorl_StopPhotoing" object:nil];
        return;
    }
    
}

@end
