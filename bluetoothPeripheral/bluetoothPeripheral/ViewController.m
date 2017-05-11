//
//  ViewController.m
//  bluetoothPeripheral
//
//  Created by wutaotao on 2017/5/11.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import "BabyBluetooth.h"

@interface ViewController ()
{
    BabyBluetooth *baby;
}

@property (weak, nonatomic) IBOutlet UILabel *getedinfoLabel;


@property (weak, nonatomic) IBOutlet UITextField *sendTextFiled;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //配置第一个服务s1
    CBMutableService *s1 = makeCBService(@"FFF0");
    //配置s1的3个characteristic
//    makeCharacteristicToService(s1, @"FFF1", @"r", @"hello1");//读
//    makeCharacteristicToService(s1, @"FFF2", @"w", @"hello2");//写
    makeCharacteristicToService(s1, genUUID(), @"rw", _getedinfoLabel.text);//可读写,uuid自动生成
    
//    makeCharacteristicToService(s1, @"FFF4", nil, @"hello4");//默认读写字段
//    makeCharacteristicToService(s1, @"FFF5", @"n", @"hello5");//notify字段
//    //配置第一个服务s2
//    CBMutableService *s2 = makeCBService(@"FFE0");
//    makeStaticCharacteristicToService(s2, genUUID(), @"hello6", [@"a" dataUsingEncoding:NSUTF8StringEncoding]);//一个含初值的字段，该字段权限只能是只读
    
    //实例化baby
    baby = [BabyBluetooth shareBabyBluetooth];
    //配置委托
    [self babyDelegate];
    //启动外设
    baby.bePeripheral().addServices(@[s1]).startAdvertising();

    
}

//设置蓝牙外设模式的委托
-(void)babyDelegate{
     __block ViewController   * weakself = self;
    //设置添加service委托 | set didAddService block
    [baby peripheralModelBlockOnPeripheralManagerDidUpdateState:^(CBPeripheralManager *peripheral) {
        NSLog(@"PeripheralManager trun status code: %ld",(long)peripheral.state);
    }];
    
    //设置添加service委托 | set didAddService block
    [baby peripheralModelBlockOnDidStartAdvertising:^(CBPeripheralManager *peripheral, NSError *error) {
        NSLog(@"didStartAdvertising !!!");
    }];
    
    //设置添加service委托 | set didAddService block
    [baby peripheralModelBlockOnDidAddService:^(CBPeripheralManager *peripheral, CBService *service, NSError *error) {
        NSLog(@"Did Add Service uuid: %@ ",service.UUID);
    }];
    
    [baby peripheralModelBlockOnDidReceiveWriteRequests:^(CBPeripheralManager *peripheral, NSArray *requests) {
//        weakself.getedinfoLabel.text=
        
    }];
    
    
    
    //.....
}
- (IBAction)sendBtnDidClicked:(id)sender {
}


@end
