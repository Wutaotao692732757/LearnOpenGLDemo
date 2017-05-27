//
//  bigSizeImageView.h
//  EX_appIOS
//
//  Created by mac_w on 2016/11/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BottonScrollView.h"
#import "KondonPhotoModel.h"
#import "KondorViewVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "KondorMoviePlayerController.h"


@interface bigSizeImageView : UIView

//月份提示label
@property(nonatomic,strong) UILabel *tipsLabel;

//浏览的大图
@property(nonatomic,strong) UIImageView *bigImage;

//底部滚动的视图
@property(nonatomic,strong) BottonScrollView *bottonScrollerView;

//视图数组--视图的URL
@property(nonatomic,strong) NSMutableArray *imgArr;

//压缩过的视图数组
@property(nonatomic,strong) NSMutableArray *scaledImgArr;

@property(nonatomic,assign) NSInteger selectedInt;
//选中的模型
@property(nonatomic,strong) KondonPhotoModel *selectedmodel;

//播放按钮
@property(nonatomic,strong) UIButton *playButton;

@property(nonatomic,strong) AVPlayerLayer *playerlayer;
@property(nonatomic,strong) AVPlayer *player;
@property (nonatomic, strong) KondorMoviePlayerController  *movieplayer ;

@property (nonatomic,strong) dispatch_queue_t bigImagequeue;


-(void)removePlayerLayer;

@end
