//
//  cameraPhotoVC.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/11.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "cameraPhotoVC.h"
#import "CameraTool.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+WaterMark.h"


@interface cameraPhotoVC ()


@property(nonatomic,strong)NSMutableArray *caremaFileArr;

@property(nonatomic,copy) NSString *totalPath;

@property(nonatomic,strong) UIButton *cameraBtn;

@end

@implementation cameraPhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.text=@"CAMERA PHOTOS";
    titleLabel.font=[UIFont fontWithName:@"DINOffc-Medi" size:20];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    if (![[CameraTool shareTool] isConnecting]) {
        
        [[CameraTool shareTool] connectingOperate];
    }

    [self.view addSubview:self.cameraBtn];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDCIM_path:) name:@"requestreadDCIM_PathSuccess" object:nil];
    
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllFilePath:) name:@"readPlistSuccess" object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self loadImagesFromCamera];
    });
    
}


-(void)loadImagesFromCamera{
    
    
    [[CameraTool shareTool] readDCIM_Path];
    
    
    
}

-(void)getDCIM_path:(NSNotification *)dic{
    
    [[CameraTool shareTool] getFilePlist];
    NSDictionary *newdic=dic.object;
    
    _totalPath=newdic[@"pwd"];
    
//    backStr:{"rval":0,"msg_id":1283,"pwd":"/tmp/SD0/DCIM/100MEDIA"}
    NSLog(@"22222---%@",_totalPath);
    
}

-(void)getAllFilePath:(NSNotification *)noti{
    
    NSDictionary *dic=noti.object;
    NSArray *plistArr = dic[@"listing"];
    _caremaFileArr = [NSMutableArray array];
    for (NSDictionary *currentDic in plistArr) {
        NSString *string = [[currentDic allKeys] firstObject];
        if ([string rangeOfString:@"_thm."].location == NSNotFound&&[string rangeOfString:@".THM"].location == NSNotFound) {
            [_caremaFileArr addObject:string];
        }
    }
    NSArray *tmpArr = [NSArray array];
    tmpArr = [[_caremaFileArr reverseObjectEnumerator]allObjects];
    _caremaFileArr = [tmpArr mutableCopy];
    if (_caremaFileArr) {
        NSString *firstPath = _caremaFileArr[10];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.42.1/DCIM/100MEDIA/%@",firstPath]];
        if ([firstPath hasSuffix:@"mp4"] || [firstPath hasSuffix:@"MP4"]) {
//            
//            UIButton * button=[[UIButton alloc]init];
//            
//        [self setCurrentBtn:self.cameraBtn withURL:url];
            NSLog(@"ssssssffds");
        }else if ([firstPath hasSuffix:@"jpg"] || [firstPath hasSuffix:@"JPG"]){
            
            NSLog(@"22222222");
 
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, 80, 100, 100)];
                    imageView.image=image;
                    
                    [self.view addSubview:imageView];
                    
//                                        UIImage *img = [UIImage OriginImage:image scaleToSize:CGSizeMake(self.localHeight.constant, self.localHeight.constant-10)];
                    //                    if (img) [self.cameraBtn setImage:img forState:UIControlStateNormal];
                });
            });
            
        }
    }

    NSLog(@"%@",dic.description);
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UITabBarController *tabbarVC=self.navigationController.tabBarController;
    
    UITabBarItem *item = tabbarVC.tabBar.items[0];
    item.image=[UIImage imageNamed:@"EX_App_MAIN MENU_VIEWER"];
    item.selectedImage=[UIImage imageNamed:@"EX_App_MAIN MENU_VIEWER"];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UITabBarController *tabbarVC=self.navigationController.tabBarController;
    
    UITabBarItem *item = tabbarVC.tabBar.items[0];
    item.image=[UIImage imageNamed:@"EX_App_VIEWER_CAMERA"];
    item.selectedImage=[UIImage imageNamed:@"EX_App_VIEWER_CAMERA"];
      [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(UIButton *)cameraBtn
{
    
    if (_cameraBtn==nil) {
        _cameraBtn=[[UIButton alloc]initWithFrame:CGRectMake(50, 100, 200, 100)];
    }
    return _cameraBtn;
    
}


@end
