//
//  AppDelegate.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "AppDelegate.h"
#import "KondorTabbarVC.h"
#import "KondorSettingVC.h"
#import "KondorMenuVC.h"
#import "KondorViewVC.h"
#import "KondorNavigationVC.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc]initWithFrame:CGRectMake(0, 0, ScreenW,ScreenH)];
    
    KondorTabbarVC *tabbarVC = [[KondorTabbarVC alloc]init];
    
    KondorViewVC *ViewVC=[[KondorViewVC alloc]init];
    KondorMenuVC *menuVC = [[KondorMenuVC alloc]init];
    KondorSettingVC *settingVC = [[KondorSettingVC alloc]init];
    
    KondorNavigationVC *ViewerNav=[[KondorNavigationVC alloc]initWithRootViewController:ViewVC];
//    ViewVC.title=@"VIEWER";
    ViewVC.loadDataFormNet=NO;
    
    
    KondorNavigationVC *menuNav = [[KondorNavigationVC alloc]initWithRootViewController:menuVC];
//    menuVC.title=@"MAIN MENU";
    KondorNavigationVC *settingNav = [[KondorNavigationVC alloc]initWithRootViewController:settingVC];
    settingVC.title=@"SETTINGS";
    
//    EX_App_VIEWER_CAMERA@2x    EX_App_MAIN MENU_VIEWER
    [tabbarVC addChildViewCOntrollerWithController:ViewerNav WithName:@"LIBRARY" AndImageName:@"EX_App_MAIN MENU_VIEWER" WithTag:0];
    [tabbarVC addChildViewCOntrollerWithController:menuNav WithName:@"MENU" AndImageName:@"EX_App_MAIN MENU_MENU" WithTag:1];
    [tabbarVC addChildViewCOntrollerWithController:settingNav WithName:@"SETTINGS" AndImageName:@"EX_App_MAIN MENU_SETTINGS" WithTag:2];
    
    
    [tabbarVC setSelectedIndex:1];
    self.window.rootViewController=tabbarVC;
    [self.window makeKeyAndVisible];
    UINavigationBar * navigationBar = [UINavigationBar appearance];
    [navigationBar setTintColor:[UIColor whiteColor]];
    
    //设置返回样式图片
    
//    UIImage *image = [UIImage imageNamed:@"EX_App_MAIN MENU_三角形"];
//    
//    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    navigationBar.backIndicatorImage = image;
//    
//    navigationBar.backIndicatorTransitionMaskImage = image;
//    
//    navigationBar.backIndicatorImage = [UIImage imageNamed:@"backHightLight"];
//    
//    UIBarButtonItem *buttonItem = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
//    
//    UIOffset offset;
//    offset.horizontal = -100;
//    
//    [buttonItem setBackButtonTitlePositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
//    [SDImageCache sharedImageCache].maxMemoryCost=1024*1024*30;
//    [SDImageCache sharedImageCache].maxMemoryCountLimit=3;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    if([[WTMoiveObject sharedPlayer] timer]!=nil&&[[WTMoiveObject sharedPlayer] sourceImageView]!=nil){
        [[WTMoiveObject sharedPlayer] StopPlay];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if([[WTMoiveObject sharedPlayer] timer]!=nil&&[[WTMoiveObject sharedPlayer] sourceImageView]!=nil){
          [[WTMoiveObject sharedPlayer] PlayerContinue];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[SDImageCache sharedImageCache] clearMemory];
//    [[SDWebImageManager sharedManager] cancelAll];
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (_allowRotation == 1) {
        return UIInterfaceOrientationMaskAll;
    }
        return (UIInterfaceOrientationMaskPortrait);
    
}

// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    if (_allowRotation == 1) {
        return YES;
    }
    return NO;
}

@end
