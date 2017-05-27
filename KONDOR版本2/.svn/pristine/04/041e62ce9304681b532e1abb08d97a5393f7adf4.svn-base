//
//  CameraTool.h
//  AEE
//
//  Created by aee on 16/6/1.
//  Copyright (c) 2016年 LIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraTool : NSObject
+ (id)shareTool;
- (void)connectingOperate;//连接操作
- (void)disconnectOperate;//断开连接
- (void)recordOperate;//录像操作
- (void)recordStopOperate;//停止录像
- (void)shutterOperate;//拍照操作
- (void)getAllOptions;//获取所有属性
- (void)deleteFiles:(NSString *)str;//删除文件
- (void)setOptionsMode:(NSString *)status Type:(NSString*)type;//具体一个属性的设置
- (void)setWiFiInfoWithNewNameAndPassword:(NSString *)info;//设置WiFi名
- (void)getSingleWithOption:(NSString *)option;//获取单个功能下的所有属性
- (void)stopVF;//断开码流
- (void)resetVF;//重置码流
- (void)stopLastPhoto;//停止连拍
- (void)getRecordingTime;//获取录像时间
- (void)zoomIn;//视频实时缩小
- (void)zoomOut;//视频实时放大
- (void)traversePath:(NSString *)path;//查找路径是否合法
- (void)getWiFiConfigFile;//获取WIFI的配置文件
- (void)refreshWifiConfigFile:(int)size md5:(NSString*)md5;//重置wifi配置信息
- (void)restartWifi;//重启WiFi
- (void)logoInPutFileTCP;  // 连接打开TCP端口
- (void)updateFileWithPutFile;  //升级
- (void)putfileBin:(int)size md5:(NSString*)md5; // bin文件升级
- (void)readDCIM_Path;//查找路径是否合法
- (void)getFilePlist;//获取回放所有的文件信息
- (void)formatSDCard;//格式化
- (void)initDefaultSetting;//恢复出厂设置
- (void)setNoAction; // 三个不动作
- (void)setYawDirectionWithLeft;    //手持云台 偏航Yaw向左转动
- (void)setYawDirectionWithRight;   //手持云台 偏航Yaw向右转动
- (void)setPitchDirectionWithUp;    //手持云台 俯仰Pitch向上转动
- (void)setPitchDirectionWithDown;  //手持云台 俯仰Pitch向下转动
- (void)setHandleRestart;         //手持云台 归中模式
- (void)setHandleInputAutoPhoto;    //手持云台 自拍模式
- (void)setHandleLockMode;       //手持云台 锁定模式
- (void)setRollDirectionWithUp:(int)data;    //手持云台 横滚roll向上滚动      data为  0-63
- (void)setRollDirectionWithDown:(int)data;    //手持云台 横滚roll向下滚动
- (void)setSaveInfo:(int)data;    //手持云台 横滚roll保存校准数据
- (void)setHandleFollowMe;    //手持云台 跟随模式
@property (nonatomic,strong)void(^getRefreshData)(NSDictionary *);
@property (assign,nonatomic)BOOL isATwelve,isConnecting,isHandleControl;

@property (nonatomic,assign) NSInteger timerCount;

@end
/*******
0  1  2  3  4  5  6  7
 yaw   pitch   Mode
 00    00     000不动作
 01向左 01向上 001归中
 10    10     010自拍
              011锁定
              100跟随
******/
