//
//  ViewController.m
//  WTNEWPlayer
//
//  Created by wutaotao on 2017/6/5.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import "WTVIDEOPLAYER.h"


@interface ViewController ()
@property(nonatomic,strong) WTVIDEOPLAYER *player;
//
@property (weak, nonatomic) IBOutlet LYOpenGLView *openglView;
 
@property (nonatomic , strong) LYOpenGLView *mOpenGLView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.openglView setupGL];
  _player =  [[WTVIDEOPLAYER alloc]initWithVideo:@"rtsp://192.168.42.1/live"];
    _player.lyOpenGLView = self.openglView;
}


//void addBlockToArray(NSMutableArray *array) {
//   
//    char b = 'b';
//    [array addObject:^{
//        printf("%cCC\n",b);
//    }];
//    
//    
//}
//
//void exampleA(){
//    NSMutableArray *array = [NSMutableArray array];
//    
//    addBlockToArray(array);
//    void(^block)() = [array objectAtIndex:0];
//    
//    block();
//    
//}
- (IBAction)videoplayBtnDidClicked:(id)sender {
    
    [_player decodeFrame];
    
}


@end
