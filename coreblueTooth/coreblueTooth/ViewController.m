//
//  ViewController.m
//  coreblueTooth
//
//  Created by wutaotao on 2017/5/11.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"

#import "BabyBluetooth.h"
#import "SVProgressHUD.h"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    BabyBluetooth *baby;
}

@property(nonatomic,strong)NSMutableArray *deviceArr;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UITextField *textViewInfo;

@property (nonatomic,strong) NSMutableArray *peripheralArr;

@property (nonatomic,strong)CBPeripheral *currPeripheral;
@property(nonatomic,strong)  CBCharacteristic*characteristic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceArr=[NSMutableArray array];
    _peripheralArr=[NSMutableArray array];
    baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];
    baby.scanForPeripherals().begin();

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return _peripheralArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"device"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"device"];
        
    }
    
    CBPeripheral *peripheral = _peripheralArr[indexPath.row];
    cell.textLabel.text=peripheral.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     CBPeripheral *peripheral = _peripheralArr[indexPath.row];
 
    self.currPeripheral=peripheral;
    [self loadData];
    
    
    
}
-(void)loadData{
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    baby.having(self.currPeripheral).and.channel(@"FFF0").then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    
}

//设置蓝牙委托
-(void)babyDelegate{
    
    //设置扫描到设备的委托
  __block ViewController   * weakself = self;
//  __block BabyBluetooth * weakbaby = baby ;
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if(![weakself.peripheralArr containsObject:peripheral]){
         
            [weakself.peripheralArr addObject:peripheral];
            [weakself.tableView reloadData];
        }
        NSLog(@"搜索到了设备:%@",peripheral.name);
 
    }];
    
    
    
    
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
       
    }];
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"连接失败了");
    }];
    //设置发现设service的Characteristics的委托
//    [baby setBlockOnDiscoverCharacteristicsAtChannel:@"FFF0" block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
//        NSLog(@"==服务的名字=service name:%@",service.UUID);
//        //插入row到tableview
//     
//        
//    }];
    //设置读取characteristics的委托
//    [baby setBlockOnReadValueForCharacteristicAtChannel:@"FFF0" block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//        
//            weakself.characteristic = characteristics;
//            NSString *str = [[NSString alloc]initWithData:characteristics.value encoding:NSUTF8StringEncoding];
//            weakself.infoLabel.text = str;
//         NSLog(@"特征的名字characteristic name:%@ value is:%@",characteristics,characteristics.value);
//        
//    }];
    
    [baby setBlockOnReadValueForCharacteristicAtChannel:@"FFF0" block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        weakself.characteristic = characteristic;
        NSString *str = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        weakself.infoLabel.text = str;
        NSLog(@"特征的名字characteristic name:%@ value is:%@",characteristic,characteristic.value);
    }];
    
    
//    //设置发现characteristics的descriptors的委托
//    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:@"FFF0" block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
//        for (CBDescriptor *d in characteristic.descriptors) {
//            NSLog(@"CBDescriptor 服务名字 name is :%@",d.UUID);
//            
//          
//           
//        }
//        
//    }];
    //设置读取Descriptor的委托
//    [baby setBlockOnReadValueForDescriptorsAtChannel:@"FFF0" block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
//        NSLog(@"描述值Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
//         weakself.infoLabel.text=[NSString stringWithFormat:@"%@",descriptor.value];
//    }];
    
    
    //过滤器
    //设置查找设备的过滤器
//    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
//        
//        NSLog(@"扫描到的设备%@",advertisementData);
//        //最常用的场景是查找某一个前缀开头的设备 most common usage is discover for peripheral that name has common prefix
//        //if ([peripheralName hasPrefix:@"Pxxxx"] ) {
//        //    return YES;
//        //}
//        //return NO;
//        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 1
//        if (peripheralName.length >1) {
//            return YES;
//        }
//        return NO;
//    }];
    
    //.......
    
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:<#(NSString *)#> block:<#^(CBCharacteristic *characteristic, NSError *error)block#>];
    
}
- (IBAction)sendBtnDidClicked:(id)sender {
    
 [self.currPeripheral writeValue:[_infoLabel.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    
      [textField resignFirstResponder];
    return YES;
}


@end
