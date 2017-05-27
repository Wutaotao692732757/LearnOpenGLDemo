//
//  KondorMenuVC.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "KondorMenuVC.h"
#import "modelSelecVC.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "CameraTool.h"
#import "KondorShowVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ModelData.h"
#import "FeedBackButton.h"


@interface KondorMenuVC ()<UIPopoverPresentationControllerDelegate,UIAlertViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UIImageView *logoView;
@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic,strong) UIButton *connectBtn;

//显示相机图像的图层
@property (nonatomic,strong) UIView *videoImageView;

//选择视频模式的按钮
@property (nonatomic,strong) UIButton *videoSelectBtn;

@property (nonatomic,strong) NSURL *mediaUrl;

@property (nonatomic,strong) modelSelecVC *menuVC;
//操作是否结束
@property (nonatomic,assign) BOOL finished;
//检测是否连接网络
@property (nonatomic,assign) BOOL hasConected;
@property (nonatomic,strong) NSTimer *checkTimer;
//是否连接的提示label
@property (nonatomic,strong) UILabel *tipsLabel;
//连接操作提示View
@property (nonatomic,strong) UIView *connectTipsView;
//操作步骤的View
@property (nonatomic,strong) UIView *walkThoughtView;
@property (nonatomic,strong) UIScrollView *walkthoughtScr;
@property (nonatomic,strong) UIPageControl *walkthoughtPage;
@property (nonatomic,strong) UIButton *nextbutton;
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) UIButton *rightItem;
//walkthroughBtn
@property (nonatomic,strong) UIButton *walkButton;

@property (nonatomic,strong) UIButton *closeButton;

@end

@implementation KondorMenuVC

static NSInteger step=0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor colorWithRed:65/255.0 green:65/255.0 blue:65/255.0 alpha:1];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.text=@"MAIN MENU";
    titleLabel.font=[UIFont fontWithName:@"DINOffc-Medi" size:20];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIImage *logoImg = [UIImage imageNamed:@"menuLOGO"];
      CGFloat logoscale=logoImg.size.height/logoImg.size.width;
    self.logoView.frame=CGRectMake(0, 64, ScreenW, ScreenW*logoscale+30);
    self.logoView.image=logoImg;
    self.logoView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.logoView];
    
//    UIImage *videoImg=[UIImage imageNamed:@"EX_App_MAIN MENU_摄像机"];
//    CGFloat scale=videoImg.size.height/videoImg.size.width;
//    self.bgView.frame=CGRectMake((ScreenW-videoImg.size.width)*0.5, (ScreenW*logoscale-videoImg.size.height)*0.5, videoImg.size.width, videoImg.size.height);
//    self.bgView.image=videoImg;
//    [self.logoView addSubview:self.bgView];
    
    UIImage *btnImg=[UIImage imageNamed:@"EX_App_MAIN MENU_1"];
    self.connectBtn.frame=CGRectMake((ScreenW-300)*0.5, CGRectGetMaxY(_logoView.frame)+(ScreenH-64-_logoView.frame.size.height-40-self.tabBarController.tabBar.frame.size.height)*0.5, 300, 40);
    [self.connectBtn setBackgroundImage:btnImg forState:UIControlStateNormal];
    [self.connectBtn setImage:[UIImage imageNamed:@"EX_App_MAIN MENU_WIFI"] forState:UIControlStateNormal];
    
    [self.connectBtn setTitle:@"CONNECT TO CAMERA" forState:UIControlStateNormal];
    [self.connectBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.connectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
   
    [self.view addSubview:self.connectBtn];
    
//    _checkTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkIfConnectToNet) userInfo:nil repeats:YES];
//    [self.view addSubview:self.connectTipsView];
    
   
    _rightItem=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_rightItem setImage:[UIImage imageNamed:@"INFO_ICON"] forState:UIControlStateNormal];
    [_rightItem setImage:[UIImage imageNamed:@"INFO_ICON_RED"] forState:UIControlStateHighlighted];
    [_rightItem addTarget:self action:@selector(getabackwalkThought) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_rightItem];
    
//    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [_backBtn setImage:[UIImage imageNamed:@"LIVE VIEW_3_"] forState:UIControlStateNormal];
//    [_backBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
//    
//    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_backBtn];
//    
//    [_backBtn addTarget:self action:@selector(backBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)backBtnDidClicked{
    
    if ([_connectBtn.currentTitle isEqualToString:@"CONNECT TO CAMERA"]) return;
    
    [_backBtn setImage:[UIImage imageNamed:@"backHightLight"] forState:UIControlStateNormal];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [_backBtn setImage:[UIImage imageNamed:@"LIVE VIEW_3_"] forState:UIControlStateNormal];
        _hasConected=NO;
        [self.cameraTipView removeFromSuperview];
        _logoView.image=[UIImage imageNamed:@"menuLOGO"];
        //        _bgView.image=[UIImage imageNamed:@"menuLOGO"];
        _rightItem.hidden=NO;
        [self.cameraTipView removeFromSuperview];
        [self.connectBtn setTitle:@"CONNECT TO CAMERA" forState:UIControlStateNormal];
        
    });
    
    
}



-(void)getabackwalkThought{
    
    BOOL hasTipsView = [_connectTipsView.superview isEqual:self.view];
    if (hasTipsView==YES||[self.connectBtn.currentTitle isEqualToString:@"LIVE  VIEW"]) {
        return ;
    }
    [_connectTipsView removeFromSuperview];
    [_walkThoughtView removeFromSuperview];
   
    [self.view addSubview:self.connectTipsView];
    
    
    
}



#pragma mark ---检测是否连接
-(BOOL)checkIfConnectToNet{
  
    if([[CameraTool shareTool] isConnecting]){
        [_tipsLabel removeFromSuperview];
        _hasConected=YES;
        _rightItem.hidden=YES;
      NSString *moudle=[[ModelData shareData] get_dv_info];
        NSString *vq=[[ModelData shareData] video_quality];
        NSString *vrs=[[ModelData shareData] versions];
        NSString *mm=[[ModelData shareData] moudle];
        ModelData *modeldata=[ModelData shareData];
        
        NSLog(@"-----%@---%@---%@---modeldata%@",vq,vrs,mm,modeldata.video_state);
        NSLog(@"摄像机的型号--%@",moudle);
//        AEE Lyfe Titan Ver:E.E9.8  icon_kindone
        if ([moudle containsString:@"EXTICON-4"]) {
            
            _logoView.image=nil;
            _bgView.image=nil;
            self.cameraTipView.image=[UIImage imageNamed:@"icon_kindfour"];
            [self.view addSubview:self.cameraTipView];
            
            // // // // // ...... // .... //  ... //
        }else{
            _logoView.image=nil;
            _bgView.image=nil;
            self.cameraTipView.image=[UIImage imageNamed:@"icon_kindone"];
            [self.view addSubview:self.cameraTipView];
        }
        
        [self.connectBtn setTitle:@"LIVE  VIEW" forState:UIControlStateNormal];
        
        [_bgView removeFromSuperview];
        return YES;
        
    }else{
        _hasConected=NO;
        _rightItem.hidden=NO;
        [self.cameraTipView removeFromSuperview];
        _logoView.image=[UIImage imageNamed:@"menuLOGO"];
//        _bgView.image=[UIImage imageNamed:@"menuLOGO"];
        
        [self.cameraTipView removeFromSuperview];
        [self.connectBtn setTitle:@"CONNECT TO CAMERA" forState:UIControlStateNormal];
//        [self.logoView addSubview:self.bgView];
    
    }
        return NO;
}
//-(BOOL) isConnectionAvailable{
//    
//    BOOL isExistenceNetwork = NO;
//    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
//    switch ([reach currentReachabilityStatus]) {
//        case NotReachable:
//            isExistenceNetwork = NO;
//            //NSLog(@"notReachable");
//            break;
//        case ReachableViaWiFi:
//            isExistenceNetwork = YES;
//            //NSLog(@"WIFI");
//            break;
//        case ReachableViaWWAN:
//            isExistenceNetwork = NO;
//            //NSLog(@"3G");
//            break;
//    }
//    
//  
//    
//    return isExistenceNetwork;
//}

//连接按钮点击事件
-(void)connectBtnDidClicked{
    
//  CONNECT TO CAMERA
    if ([_connectBtn.currentTitle isEqualToString:@"CONNECT TO CAMERA"]) {
        
       BOOL hasWIFI=NO;
//        
//        
        id info = nil;
       NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
       for (NSString *ifnam in ifs) {
            info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            NSString *str = info[@"SSID"];
//            NSString *str2 = info[@"BSSID"];
//            NSString *str3 = [[ NSString alloc] initWithData:info[@"SSIDDATA"] encoding:NSUTF8StringEncoding];
            if (str!=nil) {
                hasWIFI=YES;
            }
        }
        if (!hasWIFI) {
//            // push 到设置界面
//            //        [];
            //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenURLOptionsAnnotationKey]];
//            
            NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }else{
                NSURL *otherUrl = [NSURL URLWithString:@"prefs:root=WIFI"];
                if ([[UIApplication sharedApplication] canOpenURL:otherUrl]) {
                    [[UIApplication sharedApplication] openURL:otherUrl];
                }
            }

//            
            return;
       }
//        
//        
        [[CameraTool shareTool] connectingOperate];
        _connectBtn.layer.borderColor=[UIColor whiteColor].CGColor;
        _connectBtn.layer.borderWidth=2.0;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _connectBtn.layer.borderColor=[UIColor clearColor].CGColor;
            _connectBtn.layer.borderWidth=0.0;
            
            if (![self checkIfConnectToNet]) {
                
                [[CameraTool shareTool] connectingOperate];
            } ;
       });
//
    }else{
        _connectBtn.layer.borderColor=[UIColor whiteColor].CGColor;
        _connectBtn.layer.borderWidth=2.0;
        _connectBtn.enabled=NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _connectBtn.layer.borderColor=[UIColor clearColor].CGColor;
            _connectBtn.layer.borderWidth=0.0;
            _connectBtn.enabled=YES;
            [self getLiveVideoStream];
          
        });
    }
}

// get live stream
-(void)getLiveVideoStream{

        [SVProgressHUD showWithStatus:@"CONNECTING"];
        //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //
        //        [[CameraTool shareTool] resetVF];
        //    });
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
            WTMoiveObject *movieObject=[WTMoiveObject sharedPlayer];
 
//            rtmp://live.hkstv.hk.lxdns.com/live/hks
            //        rtsp://192.168.42.1/live  rtsp://192.168.3.60:8554/mk10
            [movieObject setVideoPathWithString:@"rtsp://192.168.42.1/live"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
 
                KondorShowVC *showVC = [[KondorShowVC alloc]init];
               
                [self.navigationController pushViewController:showVC animated:YES];
            });
            
        });

}

//关闭按钮点击退回到之前的状态
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==0) {
        
        [self.videoSelectBtn removeFromSuperview];
        
        [self.view addSubview:_logoView];
//        [self.view addSubview:_bgView];
        
        [self.connectBtn setImage:[UIImage imageNamed:@"EX_App_MAIN MENU_WIFI"] forState:UIControlStateNormal];
        
        [self.connectBtn setTitle:@"CONNECT TO CAMERA" forState:UIControlStateNormal];
        [self.connectBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [self.connectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    
    }
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _walkthoughtPage.currentPage=scrollView.contentOffset.x/_walkthoughtScr.frame.size.width;
    
    if (_walkthoughtPage.currentPage==3) {
        [_nextbutton setTitle:@"FINISH" forState:UIControlStateNormal];
    }else{
         [_nextbutton setTitle:@"NEXT" forState:UIControlStateNormal];
    }
        self.logoView.image=[UIImage imageNamed:@"walkthrough_one"];
}



//展开选择项目
-(void)ShowTheMenuView{
    
    if (_menuVC==nil) {
        _menuVC=[[modelSelecVC alloc]init];
    }
    
//    menuVC.view.backgroundColor=RandomColor;
    _menuVC.preferredContentSize=CGSizeMake(300, 400);
//    _menuVC.delegate=self;
    _menuVC.modalPresentationStyle=UIModalPresentationPopover;
    UIPopoverPresentationController *popVC=_menuVC.popoverPresentationController;
    
    UIBarButtonItem *vide=[[UIBarButtonItem alloc]initWithCustomView:_videoSelectBtn];
    popVC.barButtonItem=vide;
//    popVC.sourceRect=CGRectMake(0, 0, 200, 200);
    popVC.permittedArrowDirections=UIPopoverArrowDirectionUp;
    popVC.delegate=self;
    [self presentViewController:_menuVC animated:YES completion:nil];
    
}


#pragma mark -- 生命周期方法
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    
   if( ![self checkIfConnectToNet]) [[CameraTool shareTool] connectingOperate];

    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}


#pragma mark  -- 操作提示按钮点击
-(void)walkThroughButtonDidClicked{
    
    _walkButton.backgroundColor=[UIColor redColor];
    [_connectTipsView removeFromSuperview];
    
    self.logoView.image=[UIImage imageNamed:@"walkthrough_one"];
    self.bgView.image=nil;
    [self.view addSubview:self.walkThoughtView];
    
}

-(void)connectedTipViewCloseButtonDidClicked{
    [_closeButton setBackgroundColor:[UIColor redColor]];
    [_connectTipsView removeFromSuperview];

    [self.connectBtn setUserInteractionEnabled:YES];
    
}
//下一步按钮点击
-(void)walkThoughtNextButtonDidClicked{
    _nextbutton.backgroundColor=[UIColor redColor];
    step=_walkthoughtPage.currentPage;
    step+=1;
    if (step==3) {
        [_nextbutton setTitle:@"FINISH" forState:UIControlStateNormal];
    }
    if (step==4) {
        [_walkThoughtView removeFromSuperview];
        _connectBtn.userInteractionEnabled=YES;
        return ;
    }
    
    [_walkthoughtScr setContentOffset:CGPointMake(260*step, 0) animated:YES];
    _walkthoughtPage.currentPage=step;
    
    self.logoView.image=[UIImage imageNamed:@"walkthrough_one"];
  
    
}

#pragma scoket 方法连接服务器

//UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:nil message:@"YOUR PHONE IS NOT CURRENTLY CONNECTED TO THE CAMERAS WIFI FUNCTION.PLEASE CHECK YOUR CAMERA'S WIFI IS TURNED ON AND YOUR PHONE HAS SUCCESSFULLY CONNECTED. FOR ADDITIONAL HELP.VISIT THE WALK-THROUGH SECTION BELOW" delegate:self cancelButtonTitle:@"CLOSE" otherButtonTitles:@"WALKTHROUGH", nil];
//    
//    [errorAlert show];
//懒加载各个控件
-(UIImageView *)bgView
{
    if (_bgView==nil) {
        _bgView=[[UIImageView alloc]init];
    }
    return _bgView;
}

-(UIImageView *)logoView
{
    if (_logoView==nil) {
        _logoView=[[UIImageView alloc]init];
    }
    return _logoView;
}
-(UIButton *)connectBtn
{
    if (_connectBtn==nil) {
        _connectBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _connectBtn.layer.cornerRadius=20;
        _connectBtn.layer.masksToBounds=YES;
        [_connectBtn addTarget:self action:@selector(connectBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectBtn;
    
}
-(UIButton *)videoSelectBtn
{
    if (_videoSelectBtn==nil) {
        _videoSelectBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 64, ScreenW, 44)];
//        _videoSelectBtn.backgroundColor=[UIColor colorWithRed:180/255.0 green:180/255.0 blue:179/255.0 alpha:1];
         _videoSelectBtn.backgroundColor=[UIColor whiteColor];
        [_videoSelectBtn setImage:[UIImage imageNamed:@"EX_App_CAMERA_VIDEO"] forState:UIControlStateNormal];
        [_videoSelectBtn addTarget:self action:@selector(ShowTheMenuView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoSelectBtn;
}

-(UIView *)videoImageView
{
    if (_videoImageView==nil) {
        _videoImageView=[[UIView alloc]initWithFrame:CGRectMake(0, 64+44, ScreenW, ScreenH-64-80-80-44)];
    }
    return _videoImageView;
}
-(UILabel *)tipsLabel{
    if (_tipsLabel==nil) {
        _tipsLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, ScreenH-64-150, ScreenW-20, 30)];
        _tipsLabel.font=[UIFont fontWithName:@"DINOffc-Medi" size:12];
        _tipsLabel.textColor=[UIColor redColor];
        _tipsLabel.text=@"THIS OPTION REQUIRES CONNECTION TO THE CAMERA";
        _tipsLabel.textAlignment=NSTextAlignmentCenter;
        _tipsLabel.layer.cornerRadius=15;
        _tipsLabel.layer.masksToBounds=YES;
        _tipsLabel.backgroundColor=[UIColor colorWithRed:187/255.0 green:189/255.0 blue:191/255.0 alpha:1];
    }
    return _tipsLabel;
}
-(UIImageView *)cameraTipView{
    
    if (_cameraTipView==nil) {
        _cameraTipView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 64, ScreenW, ScreenW)];
//        _cameraTipView.backgroundColor=RandomColor;
    }
    return _cameraTipView;
}

-(UIView *)connectTipsView{
    
    if (_connectTipsView==nil) {
        _connectTipsView=[[UIView alloc]initWithFrame:CGRectMake((ScreenW-300)*0.5, (ScreenH-300)*0.5-20, 300, 300)];
        _connectTipsView.backgroundColor=[UIColor colorWithRed:65/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        UILabel *contipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 20, 260, 150)];
        contipLabel.text=@"YOUR PHONE IS NOT CURRENTLY CONNECTED TO THE CAMERAS WIFI FUNCTION. PLEASE CHECK YOUR CAMERA'S WIFI IS TURNED ON AND YOUR PHONE HAS SUCCESSFULLY CONNECTED. FOR ADDITIONAL HELP, VISIT THE WALK-THROUGH SECTION BELOW.";
        contipLabel.textColor=[UIColor whiteColor];
        contipLabel.numberOfLines=0;
        contipLabel.textAlignment=NSTextAlignmentCenter;
        contipLabel.font=[UIFont fontWithName:@"DINOffc-Medi" size:14];
        
        _walkButton=[[FeedBackButton alloc]initWithFrame:CGRectMake(0, 190, 300, 50)];
        [_walkButton setTitle:@"WALKTHROUGH" forState:UIControlStateNormal];
        UIButton *closeButton=[[FeedBackButton alloc]initWithFrame:CGRectMake(0, 250, 300, 50)];
        _closeButton=closeButton;
        [closeButton setTitle:@"CLOSE" forState:UIControlStateNormal];
        _walkButton.backgroundColor=[UIColor redColor];
        closeButton.backgroundColor=[UIColor redColor];
        [_walkButton addTarget:self action:@selector(walkThroughButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [closeButton addTarget:self action:@selector(connectedTipViewCloseButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        
        [_connectTipsView addSubview:contipLabel];
        [_connectTipsView addSubview:_walkButton];
        [_connectTipsView addSubview:closeButton];
        
        _connectTipsView.layer.cornerRadius=20;
        _connectTipsView.layer.masksToBounds=YES;
        _connectTipsView.layer.borderColor=[UIColor colorWithRed:233.0/255.0 green:73.0/255.0 blue:74.0/255.0 alpha:1].CGColor;
        _connectTipsView.layer.borderWidth=2.0;
    }
    
    return _connectTipsView;
}

-(UIView *)walkThoughtView{
    
    if (_walkThoughtView==nil) {
        
        _walkThoughtView=[[UIView alloc]initWithFrame:CGRectMake((ScreenW-300)*0.5, ScreenH-280, 300, 200)];
        
        _walkThoughtView.backgroundColor=[UIColor colorWithRed:65/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        
        _walkthoughtScr=[[UIScrollView alloc]initWithFrame:CGRectMake(20, 10, 260, 120)];
        UILabel *tip1=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 260, 120)];
        tip1.text=@"PRESS AND HOLD THE CAMERAS WI-FI/MENU BUTTON FOR 5 SECONDS, RELEASE AND WAIT FOR THE BLUE WIFI INDICATOR TO START FLASHING";
        tip1.font=[UIFont fontWithName:@"DINOffc-Medi" size:14];
        tip1.textAlignment=NSTextAlignmentCenter;
        tip1.numberOfLines=0;
        tip1.textColor=[UIColor whiteColor];
        
        UILabel *tip2=[[UILabel alloc]initWithFrame:CGRectMake(260, 0, 260, 120)];
        tip2.text=@"WHEN YOUR CAMERA'S WIFI IS TURNED ON, IT WILL NOW BE DISCOVERABLE. GO TO YOUR DEVICES WI-FI SETTINGS AND SELECT THE 'EXTREME ICON' FROM THE LIST. THE PASSWORD BY DEFAULT IS 'Extreme123'";
        tip2.font=[UIFont fontWithName:@"DINOffc-Medi" size:14];
        tip2.textAlignment=NSTextAlignmentCenter;
        tip2.numberOfLines=0;
        tip2.textColor=[UIColor whiteColor];
        
        UILabel *tip3=[[UILabel alloc]initWithFrame:CGRectMake(260*2, 0, 260, 120)];
        tip3.text=@"WHEN YOUR DEVICE HAS SUCCESSFULLY CONNECTED TO THE CAMERA,OPEN THE EXTREME ICON APPLICATION AND SELECT THE 'LIVE VIEW' BUTTON";
        tip3.font=[UIFont fontWithName:@"DINOffc-Medi" size:14];
        tip3.textAlignment=NSTextAlignmentCenter;
        tip3.numberOfLines=0;
        tip3.textColor=[UIColor whiteColor];
        
        UILabel *tip4=[[UILabel alloc]initWithFrame:CGRectMake(260*3, 0, 260, 120)];
        tip4.text=@"IF YOUR DEVICE HAS NOT MADE A SUCCESSFULL CONNECTION TO THE CAMERA, THE'CONNECT TO CAMERA'BUTTON WILL STILL BE VISIBLE";
        tip4.font=[UIFont fontWithName:@"DINOffc-Medi" size:14];
        tip4.textAlignment=NSTextAlignmentCenter;
        tip4.numberOfLines=0;
        tip4.textColor=[UIColor whiteColor];
        
        [_walkthoughtScr addSubview:tip1];
        [_walkthoughtScr addSubview:tip2];
        [_walkthoughtScr addSubview:tip3];
        [_walkthoughtScr addSubview:tip4];
        [_walkthoughtScr setContentSize:CGSizeMake(260*4, 100)];
        _walkthoughtScr.scrollEnabled=NO;
        [_walkThoughtView addSubview:_walkthoughtScr];
        _walkthoughtScr.scrollEnabled=YES;
        _walkthoughtScr.pagingEnabled=YES;
        _walkthoughtScr.showsVerticalScrollIndicator=NO;
        _walkthoughtScr.showsHorizontalScrollIndicator=NO;
        _walkthoughtScr.delegate=self;
        
        //页码视图
        _walkthoughtPage=[[UIPageControl alloc]initWithFrame:CGRectMake(270*0.5, 130, 30, 10)];
        _walkthoughtPage.currentPage=0;
        _walkthoughtPage.pageIndicatorTintColor=[UIColor lightGrayColor];
        _walkthoughtPage.currentPageIndicatorTintColor=[UIColor whiteColor];
        _walkthoughtPage.numberOfPages=4;
        [_walkThoughtView addSubview:_walkthoughtPage];
        
        //底部按钮
        _nextbutton=[[FeedBackButton alloc]initWithFrame:CGRectMake(0, 150, 300, 50)];
        _nextbutton.backgroundColor=[UIColor redColor];
        [_nextbutton setTitle:@"NEXT" forState:UIControlStateNormal];
    
        [_walkThoughtView addSubview:_nextbutton];
        [_nextbutton addTarget:self action:@selector(walkThoughtNextButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        _walkThoughtView.layer.cornerRadius=20;
        _walkThoughtView.layer.masksToBounds=YES;
        _walkThoughtView.layer.borderColor=[UIColor colorWithRed:233.0/255.0 green:73.0/255.0 blue:74.0/255.0 alpha:1].CGColor;
        _walkThoughtView.layer.borderWidth=2.0;
    }
    
    return _walkThoughtView;
}



@end
