//
//  KondorTabbarVC.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "KondorTabbarVC.h"

@interface KondorTabbarVC ()

@end

@implementation KondorTabbarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.tabBarController.view.backgroundColor=[UIColor colorWithRed:167/255.0 green:79/255.0 blue:84/255.0 alpha:1];
    
    
    
    [self.tabBar setBackgroundColor:[UIColor colorWithRed:167/255.0 green:79/255.0 blue:84/255.0 alpha:1]];
    [self.tabBar setBackgroundImage:[UIImage new]];
    [self.tabBar setTintColor:[UIColor whiteColor]];
    
    
 
    

   
    
    
    
//    UIImageView *line1 = [[UIImageView alloc]initWithFrame:CGRectMake(rect.origin.x+rect.size.width, 2, 2, 46)];
//    line1.backgroundColor=[UIColor whiteColor];
//    
//    [self.tabBar insertSubview:line1 atIndex:0];
//    
//    UIImageView *line2 = [[UIImageView alloc]initWithFrame:CGRectMake(self.tabBar.itemWidth, 2, 2, 46)];
//    line2.backgroundColor=[UIColor whiteColor];
//    [self.tabBar insertSubview:line2 atIndex:0];
}

-(void)addChildViewCOntrollerWithController:(UIViewController *)controller WithName:(NSString *)titleName AndImageName:(NSString *)imageName WithTag:(NSInteger)tag{
    
    [self addChildViewController:controller];
    controller.tabBarItem=[[UITabBarItem alloc]initWithTitle:titleName image:[UIImage imageNamed:imageName] tag:0];

    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSInteger count =0 ;  CGFloat padding = 0;
    for (UIView *bview in [self.tabBar subviews]) {
        
        if ([bview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            count++;
            if (count==3) return;
            
            
            if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
                NSLog(@"----shishenme -- %@",[UIDevice currentDevice].model);
                
                padding = 20;
                
            }
            
            UIImageView *line1 = [[UIImageView alloc]initWithFrame:CGRectMake(bview.bounds.size.width-2+padding, 2, 2, bview.bounds.size.height)];
            line1.backgroundColor=[UIColor whiteColor];
            [bview addSubview:line1];
            
        }
        
        
    }
    
}



@end
