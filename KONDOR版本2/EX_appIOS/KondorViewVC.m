//
//  KondorViewVC.m
//  EX_appIOS
//
//  Created by mac_w on 2016/11/8.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "KondorViewVC.h"
#import "KondorSectionHeaderView.h"
#import "KondorCollectionCell.h"
#import "bigSizeImageView.h"
#import "UIImage+WaterMark.h"
#import "cameraPhotoVC.h"
#import "KondorCollectionView.h"
#import "CameraTool.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+WaterMark.h"
#import "KondonPhotoModel.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Reachability.h"
#import "chooseDeviceView.h"
#import "SizeModel.h"
#import "KondorSession.h"
#import "AppDelegate.h"


#define sanbox  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]

typedef int (^blk)(int , int);

@interface KondorViewVC ()<UICollectionViewDelegate,UICollectionViewDataSource,cellselectedDelegate,NSURLSessionDownloadDelegate,chooseViewDelegate,UIDocumentInteractionControllerDelegate,UIAlertViewDelegate>
//相机相册的Collection
@property(nonatomic,strong) UICollectionView *photoCollection;
//本地相册的Collection
@property(nonatomic,strong) UICollectionView *localCollection;

//总体的HeaderView
@property(nonatomic,strong) UIView *headerView;
//月份信息
@property(nonatomic,strong) NSMutableArray *dataArr;
//本地月份信息
@property(nonatomic,strong) NSMutableArray *localArr;

//分享按钮
@property(nonatomic,strong) UIButton *sharedButton;
//删除按钮
@property(nonatomic,strong) UIButton *deleteButton;

//选中的照片数组
@property (nonatomic,strong) NSMutableArray *selectedArr;
//大图浏览器
@property (nonatomic,strong) bigSizeImageView *bigImgView;

//切换相机或APP相册按钮
@property (nonatomic,strong)UIButton *changeModelbtn;
//相机的状态
@property (nonatomic,assign) BOOL cammerornot;

@property (nonatomic,strong)KondorViewVC *camerVc;
//cell的重用
@property (nonatomic, strong) NSMutableDictionary *cellDic;

@property(nonatomic,strong) NSMutableArray* localFileArr;

//提示视图
@property(nonatomic,strong) UIImageView *tipsView;

@property(nonatomic,strong) NSURLSessionDownloadTask *task;

@property(nonatomic,strong)KondonPhotoModel *selectedmodel;
//Location按钮
@property(nonatomic,strong)UIButton *locationBtn;
//titleView
@property(nonatomic,strong)UILabel *titleLabel;

//选择视图
@property(nonatomic,strong)chooseDeviceView *choseView;

//蒙版视图
@property(nonatomic,strong) UIImageView *maskView;

@property(nonatomic,strong)NSMutableArray *sizeModelArr;

//progressView
@property(nonatomic,strong)UIView *progressArrView;

//显示进度的视图
@property(nonatomic,strong)UIProgressView *progressView;
//表示是什么进度的label
@property(nonatomic,strong)UILabel *progressNameLabel;
//删除或者下载取消按钮
@property(nonatomic,strong)UIButton *deleteCancelBtn;
//显示完成度的label
@property(nonatomic,strong)UILabel *successPercentLabel;

@property (nonatomic,strong) UIDocumentInteractionController *documentInteractionController;
//视频加载线程
@property (nonatomic,strong)dispatch_queue_t que;
//本地视频加载线程
@property (nonatomic,strong)dispatch_queue_t locaque;

//大图加载线程
@property (nonatomic,strong)dispatch_queue_t bigImageque;

@property (nonatomic,strong)NSOperationQueue *Downqueue;

//返回按钮。点击取消选中
@property (nonatomic,strong) UIButton *backBtn;

//是否在显示大图
@property (nonatomic,assign) BOOL hasShowingBigPic;

//下载提示
@property (nonatomic,strong)  UIAlertView *downloadAlertView;

@property (nonatomic,strong) NSMutableArray *downTaskArr;

@property (nonatomic,strong)  UIImageView *line1 ;
@end

@implementation KondorViewVC

//下载按钮点击事件
double totalSize;
NSInteger totalItem;
double totalrecived;

//刷新的次数
NSInteger resfreshTimes;
//删除错误个数
NSInteger deleteErrorItem;
//当前操作的项
KondonPhotoModel *deletingItem;
//将成功项目添加入的数组
NSMutableArray * successArr;

NSInteger cellNumber;

NSInteger  DownloadingIndex=0;

NSIndexPath *selectedindex;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor grayColor];
    _titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    _titleLabel.text=@"  DEVICE  LIBRARY  ";
    _titleLabel.font=[UIFont fontWithName:@"DINOffc-Medi" size:20];
    _titleLabel.textColor=[UIColor whiteColor];
    _titleLabel.textAlignment=NSTextAlignmentCenter;
   
    self.navigationItem.titleView=_titleLabel;
//    self.navigationItem.titleView.backgroundColor=RandomColor;
    
    if ([[CameraTool shareTool] isConnecting]==NO) {
        
        [[CameraTool shareTool] connectingOperate];
    }
        [self loadDateFromNetOrApp];
   _que = dispatch_queue_create("com.Steak.GCD", DISPATCH_QUEUE_SERIAL);
   _bigImageque = dispatch_queue_create("com.bigSteak.GCD", DISPATCH_QUEUE_SERIAL);
   _locaque = dispatch_queue_create("com.locationSteak.GCD", DISPATCH_QUEUE_SERIAL);
    _Downqueue = [[NSOperationQueue alloc] init];
    [_Downqueue setMaxConcurrentOperationCount:1];
//    _Downqueue.operations
    
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_backBtn setImage:[UIImage imageNamed:@"LIVE VIEW_3_"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_backBtn];
    
    [_backBtn addTarget:self action:@selector(backBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, ScreenW, 44)];
    _headerView.backgroundColor=[UIColor colorWithRed:167/255.0 green:79/255.0 blue:84/255.0 alpha:1];
    _sharedButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
   
    [_sharedButton setTitleEdgeInsets:UIEdgeInsetsMake(25, 0, 0, 0)];
    NSAttributedString *str1=[[NSAttributedString alloc]initWithString:@"SHARE" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [_sharedButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 15, -60)];
    [_sharedButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [_sharedButton setAttributedTitle:str1 forState:UIControlStateNormal];
    [_sharedButton addTarget:self action:@selector(downloadbuttonDidClicked) forControlEvents:UIControlEventTouchUpInside];

    _deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(ScreenW-120, 0, 100, 44)];
    [_deleteButton setImage:[UIImage imageNamed:@"EX_App_VIEWER_DELETE"] forState:UIControlStateNormal];
    
    NSAttributedString *str=[[NSAttributedString alloc]initWithString:@"DELETE" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [_deleteButton setAttributedTitle:str forState:UIControlStateNormal];
    
    [_deleteButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 15, -60)];
    [_deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(25, 0, 0, 0)];
    [_deleteButton addTarget:self action:@selector(deleteButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _locationBtn=[[UIButton alloc]initWithFrame:CGRectMake((ScreenW-100)*0.5, 0, 100, 44)];
    [_locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    
    NSAttributedString *loactionstr=[[NSAttributedString alloc]initWithString:@"LOCATION" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [_locationBtn setAttributedTitle:loactionstr forState:UIControlStateNormal];
    
    [_locationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 15, -65)];
    [_locationBtn setTitleEdgeInsets:UIEdgeInsetsMake(20, -15, 0, 0)];
    [_locationBtn addTarget:self action:@selector(locationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [_headerView addSubview:_sharedButton];
    [_headerView addSubview:_deleteButton];
    [_headerView addSubview:_locationBtn];
     [self.view addSubview:_headerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allowFullScreeenOrNot) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willGetOutScreen) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    
    [self addSomeCameraNotiFication];
    
}



#pragma mark -- 是否允许横竖屏
-(void)allowFullScreeenOrNot{
    AppDelegate * appDelegate = (AppDelegate * ) [UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 1;
    
}

-(void)willGetOutScreen{
    
    AppDelegate * appDelegate = (AppDelegate * ) [UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;
    
}

#pragma mark -- 返回按钮点击
-(void)backBtnDidClicked{
    
    if (_selectedArr.count==0&&_hasShowingBigPic==NO) {
         [_backBtn setImage:[UIImage imageNamed:@"backHightLight"] forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_backBtn setImage:[UIImage imageNamed:@"LIVE VIEW_3_"] forState:UIControlStateNormal];
            [self.tabBarController setSelectedIndex:1];
        });
        return;
    }else if (_hasShowingBigPic==YES){
        
        [_backBtn setImage:[UIImage imageNamed:@"backHightLight"] forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_backBtn setImage:[UIImage imageNamed:@"LIVE VIEW_3_"] forState:UIControlStateNormal];
            [self getBackToSmallscrollerView];
        });
    }else{
        
        [_backBtn setImage:[UIImage imageNamed:@"backHightLight"] forState:UIControlStateNormal];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_backBtn setImage:[UIImage imageNamed:@"LIVE VIEW_3_"] forState:UIControlStateNormal];
            
            [_selectedArr removeAllObjects];
            
          
            [self cleanSomeSelectedPhoto];
        });
        
        
    }
    
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // 按相册的月份来分
    return _loadDataFormNet==YES?self.dataArr.count:self.localArr.count;
    
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *mothArr=_loadDataFormNet==YES?self.dataArr[section]:self.localArr[section];
    return mothArr.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat height =44;
    return CGSizeMake(ScreenW, height);
}

-( UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    KondorSectionHeaderView  *headerView;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.backgroundColor=[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
        NSMutableArray *mothArr=_loadDataFormNet==YES?self.dataArr[indexPath.section]:self.localArr[indexPath.section];
        KondonPhotoModel *model=mothArr[0];
        headerView.tips=[NSString stringWithFormat:@"%@",model.timeString];
    }
    
    return headerView;
    
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier;
    // 每次先从字典中根据IndexPath取出唯一标识符
    if (_loadDataFormNet==YES) {
        
        identifier = [_cellDic objectForKey:[NSString stringWithFormat:@"%zd-%zd-%zd", indexPath.row,indexPath.section,resfreshTimes]];
    }else{
        
        identifier = [_cellDic objectForKey:[NSString stringWithFormat:@"local-%zd-%zd-%zd", indexPath.row,indexPath.section,resfreshTimes]];
    }
    // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
    if (identifier == nil) {
        if (_loadDataFormNet==YES) {
            
            identifier = [NSString stringWithFormat:@"%@%@", @"Viewer", [NSString stringWithFormat:@"%zd-%zd-%zd", indexPath.row,indexPath.section,resfreshTimes]];
            [_cellDic setValue:identifier forKey:[NSString stringWithFormat:@"%zd-%zd-%zd", indexPath.row,indexPath.section,resfreshTimes]];
        }else{
            identifier = [NSString stringWithFormat:@"%@%@-local", @"Viewer", [NSString stringWithFormat:@"%zd-%zd-%zd", indexPath.row,indexPath.section,resfreshTimes]];
            [_cellDic setValue:identifier forKey:[NSString stringWithFormat:@"local-%zd-%zd-%zd", indexPath.row,indexPath.section,resfreshTimes]];
            
        }
        // 注册Cell
        if (_loadDataFormNet==YES) {
            
            [_photoCollection registerClass:[KondorCollectionCell class] forCellWithReuseIdentifier:identifier];
        }else{
            [_localCollection registerClass:[KondorCollectionCell class] forCellWithReuseIdentifier:identifier];
        }
    }

    KondorCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        cell.backgroundColor=[UIColor colorWithRed:143/255.0 green:143/255.0 blue:142/255.0 alpha:1];
    if (_loadDataFormNet==YES) {
        cell.cellque=self.que;
    }else{
        cell.cellque=self.locaque;
    }
    
   
    if(cell.model==nil){
        cellNumber++;
        NSMutableArray *modelArr=_loadDataFormNet==YES?self.dataArr[indexPath.section]:self.localArr[indexPath.section];
        cell.model=modelArr[indexPath.row];
        cell.delegate=self;
    }
    
     return cell;
}
#pragma mark -- cell单击点击方法
//代理方法  --  单击变为了看大图
-(void)cellDidSelected{
    
    [self.photoCollection removeFromSuperview];
    
    [self.localCollection removeFromSuperview];
    _hasShowingBigPic=YES;
    [self seeSomeBigPicture];
    
}

#pragma mark --- 选中cell的方法
-(void)selectSomePicture{
    
    [self.selectedArr removeAllObjects];
    
    NSInteger counnt = _loadDataFormNet==YES?_dataArr.count:_localArr.count;
    
    for (int i=0; i<counnt; i++) {
      
        NSMutableArray *sectionArr= _loadDataFormNet==YES?_dataArr[i]:_localArr[i];
        for (int j=0; j<sectionArr.count; j++) {
            
            NSIndexPath *index = [NSIndexPath indexPathForItem:j inSection:i];
//                        NSIndexPath *index=[NSIndexPath indexPathForRow:j inSection:i];
            
            KondorCollectionCell *cell;
            
            NSIndexPath *selectedIndex ;
            if (_loadDataFormNet==YES) {
               cell = (KondorCollectionCell *)[self.photoCollection cellForItemAtIndexPath:index];
                selectedIndex = [self.photoCollection indexPathForCell:cell];
            }else{
                cell = (KondorCollectionCell *)[self.localCollection cellForItemAtIndexPath:index];
                selectedIndex = [self.localCollection indexPathForCell:cell];
            }
            
            if (cell.hasSelected==YES) {
                [cell addSubview:cell.MYmaskView];
                [self.selectedArr addObject:selectedIndex];
                NSLog(@"选择的index-row-%ld 选择的index-section-%ld",selectedIndex.item,selectedIndex.section);
                
            }else{
                [cell.MYmaskView removeFromSuperview];
            }
        }
        
    }
    
    
}


BOOL hasStopBigImageQueue;
#pragma mark ---  看大图方法
-(void)seeSomeBigPicture{
    
    
    NSInteger count =_loadDataFormNet==YES?_dataArr.count:_localArr.count;
    for (int i=0; i<count; i++) {
        
        NSMutableArray *sectionArr=_loadDataFormNet==YES?_dataArr[i]:_localArr[i];
        for (int j=0; j<sectionArr.count; j++) {
            
            NSIndexPath *index=[NSIndexPath indexPathForRow:j inSection:i];
            
            KondorCollectionCell *cell ;
            if (_loadDataFormNet==YES) {
                cell = (KondorCollectionCell *)[self.photoCollection cellForItemAtIndexPath:index];

            }else{
                cell = (KondorCollectionCell *)[self.localCollection cellForItemAtIndexPath:index];
            }
            if (cell.hasdoubleSelected==YES) {
          
                selectedindex=index;
                cell.hasdoubleSelected=NO;
                
            }
        }
        
    }
    
    
    [self.view addSubview:self.bigImgView];
    
    NSMutableArray *sectionArr=_loadDataFormNet==YES?_dataArr[selectedindex.section]:_localArr[selectedindex.section];
    KondonPhotoModel *model=sectionArr[selectedindex.row];
    
    if (_loadDataFormNet==YES) {
        
        dispatch_suspend(_que);
    }else{
        dispatch_suspend(_locaque);
    }
    
    if (hasStopBigImageQueue==YES) {
        dispatch_resume(_bigImageque);
        hasStopBigImageQueue=NO;
    }
    
    _bigImgView.bigImagequeue=_bigImageque;
    self.bigImgView.tipsLabel.text= [NSString stringWithFormat:@" %@ ",model.timeString];
    self.bigImgView.selectedmodel=model;
    self.bigImgView.bottonScrollerView.bottonSroqueue=_bigImageque;
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getBackToSmallscrollerView)];
    [tap setNumberOfTapsRequired:2];
    
    [self.bigImgView.bigImage addGestureRecognizer:tap];
    
    self.bigImgView.bottonScrollerView.modelArr=sectionArr;
    
}


#pragma mark -- 长按方法
//长按变为选中
-(void)doubletapDidClicked{
    
    [self selectSomePicture];
    
}

#pragma mark  --  添加通知
-(void)addSomeCameraNotiFication {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestreadDCIM_PathSuccess:) name:@"requestreadDCIM_PathSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllFilePath:) name:@"readPlistSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFileCompletion:) name:@"deleFileCompletion" object:nil];
}



//大图界面双击返回小图界面
-(void)getBackToSmallscrollerView{
    
    _hasShowingBigPic=NO;
    dispatch_suspend(_bigImageque);
    hasStopBigImageQueue=YES;
    if (_loadDataFormNet==YES) {
        
        dispatch_resume(_que);
    }else{
        dispatch_resume(_locaque);
    }
    
    [_bigImgView removePlayerLayer];
    
    [_bigImgView removeFromSuperview];
    
    _loadDataFormNet==YES?[self.view addSubview:_photoCollection]:[self.view addSubview:_localCollection];
    
    [self.view addSubview:_headerView];
    
}


#pragma mark ---- 网络或者APP获取文件路径

-(void)loadDateFromNetOrApp{

//    dispatch_suspend(_que);
//    dispatch_suspend(_bigImageque);
//    _que=nil;
//    _bigImageque=nil;
//    _que = dispatch_queue_create("com.Steak.GCD", DISPATCH_QUEUE_SERIAL);
//    _bigImageque = dispatch_queue_create("com.bigSteak.GCD", DISPATCH_QUEUE_SERIAL);
    
//    [_dataArr removeAllObjects];
    [_selectedArr removeAllObjects];
    [self cleanSomeSelectedPhoto];
//    [_localFileArr removeAllObjects];
//    [_photoCollection removeFromSuperview];
//    _photoCollection=nil;
    if (_needRefreshNet==YES) {
        [self.dataArr removeAllObjects];
        _needRefreshNet=NO;
    }
    
    if (_localNeedReFresh==YES) {
         [self.localArr removeAllObjects];
        _localNeedReFresh=NO;
    }
    
    
    if (_loadDataFormNet==YES) {
        
        [_localCollection removeFromSuperview];
        if (self.dataArr.count!=0) {
            
            self.photoCollection.delegate=self;
            self.photoCollection.dataSource=self;
            [self.view addSubview:self.photoCollection];

            return;
        }
        
        if(self.dataArr.count==0){
        
        _changeModelbtn.enabled=NO;
        
//        if ([[CameraTool shareTool] currentImage]) {
////            [[CameraTool shareTool] needReConnect]=
//        }
    
       
        [SVProgressHUD show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           
            if([[CameraTool shareTool] isConnecting]){
                
                [[CameraTool shareTool] readDCIM_Path];
            }else{
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:@"LOST CONNECTION"];
            }
            
        });
        
        
        }
        
    }else{
        // 从沙盒中获取图片
        [self.photoCollection removeFromSuperview];
        
        if (self.localArr.count!=0) {
            self.localCollection.delegate=self;
            self.localCollection.dataSource=self;
            [self.view addSubview:self.localCollection];
            
            return;
        }
        
        
        [self.localFileArr removeAllObjects];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray  *arr = [fileManager contentsOfDirectoryAtPath:sanbox error:nil];
        //  NSLog(@"arr %@",arr);
        for (int i = 0; i < arr.count; i++) {
            
            NSLog(@"%@",arr[i]);
            if ([arr[i] hasSuffix:@"mp4"] || [arr[i] hasSuffix:@"MP4"]||[arr[i] hasSuffix:@"JPG"] || [arr[i] hasSuffix:@"jpg"]) {
  
                KondonPhotoModel *model=[[KondonPhotoModel alloc]init];
                NSString *allpathstring=arr[i];
                NSString *nameString=allpathstring.lastPathComponent;
                NSLog(@"----%@----",nameString);
                NSArray *compansArr=[nameString componentsSeparatedByString:@"$"];
                model.timeString=compansArr[0];
                NSString *pathString=[NSString stringWithFormat:@"%@/%@",sanbox,arr[i]];
                
                NSURL *url=[NSURL URLWithString:pathString];
                model.pathUrl=url;
                NSLog(@"-----%@",url.description);
                if ([arr[i] hasSuffix:@"mp4"]||[arr[i] hasSuffix:@"MP4"]) {
                    model.isVideo=YES;
                    url=[NSURL fileURLWithPath:pathString];
                    model.pathUrl=url;
                }
                 [self.localFileArr addObject:model];
//                [self.dataArr addObject:model];
            }
        }
//        
//        if (_localFileArr.count==0) {
//            return;
//        }
        
        NSMutableArray *mothArr=[NSMutableArray array];
        for (KondonPhotoModel *model in self.localFileArr) {
        
            NSLog(@"-----%@----",model.timeString);
            if (![mothArr containsObject:model.timeString]) {
                
                [mothArr addObject:model.timeString];
                NSMutableArray *sectionArr=[NSMutableArray array];
                [sectionArr addObject:model];
                [self.localArr addObject:sectionArr];
                
            }else{
                NSInteger index = [mothArr indexOfObject:model.timeString];
                
                NSMutableArray *newsecArr=_localArr[index];
                [newsecArr addObject:model];
            }
        }
    
        [self.view addSubview:self.localCollection];
        self.localCollection.delegate=self;
        self.localCollection.dataSource=self;
          [self.view addSubview:_headerView];
        
        NSAttributedString *str1=[[NSAttributedString alloc]initWithString:@"SHARE" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]}];
          [_sharedButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 15, -60)];
        [_sharedButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [_sharedButton setAttributedTitle:str1 forState:UIControlStateNormal];
        [self.localCollection reloadData];
    }
}

- (void)requestreadDCIM_PathSuccess:(NSNotification *)noti{
    
    if (noti.object==nil){
        
        [SVProgressHUD showErrorWithStatus:@"GET FILE ERROR"]; return;
    };
    
    [self performSelector:@selector(getPlist) withObject:nil afterDelay:0.5];
}

//查找目录下的详细文件信息
- (void)getPlist{
    
    [[CameraTool shareTool] getFilePlist];
}

#pragma MARK --获取文件列表之后
-(void)getAllFilePath:(NSNotification *)noti{
    
    if (noti.object==nil) {
        [SVProgressHUD showErrorWithStatus:@"GET FILE ERROR"];
        return;
    }
    
    [SVProgressHUD dismiss];
    NSDictionary *dic=noti.object;
    NSArray *plistArr = dic[@"listing"];
    NSLog(@"----获取到的字典---%@",dic);
    
    _dataArr = [NSMutableArray array];
    NSString *totalString=@"sssss";
    NSMutableArray *StringArr=[NSMutableArray array];
    for ( NSInteger i = plistArr.count-1; i>=0; i-- ) {
        NSDictionary *currentDic=plistArr[i];
        NSString *string = [[currentDic allKeys] firstObject];
        
        if ([string rangeOfString:@"_thm."].location == NSNotFound&&[string rangeOfString:@".THM"].location == NSNotFound) {
            
            NSString *timeString=[[currentDic allValues] firstObject];
            
            NSArray *timstringArr=[timeString componentsSeparatedByString:@" "];
           
            NSString *newtotalString=timstringArr.firstObject;
            
            totalString=newtotalString;
            NSMutableArray *lastmothArr;
            if (![StringArr containsObject:newtotalString]) {
                [StringArr addObject:newtotalString];
                NSMutableArray *mothArr=[NSMutableArray array];
                
                [_dataArr addObject:mothArr];
                
                lastmothArr=mothArr;
                
            }else {
                NSInteger index=[StringArr indexOfObject:newtotalString];
                
                lastmothArr=_dataArr[index];
                
            }
                
                KondonPhotoModel *model=[[KondonPhotoModel alloc]init];
                NSString *firstPath = string;
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.42.1/DCIM/100MEDIA/%@",firstPath]];
                if ([firstPath hasSuffix:@"mp4"] || [firstPath hasSuffix:@"MP4"]) {
                    model.isVideo=YES;
                }else if ([firstPath hasSuffix:@"jpg"] || [firstPath hasSuffix:@"JPG"]){
                    model.isVideo=NO;
                }
                model.pathUrl=url;
                model.timeString=totalString;
                [lastmothArr addObject:model];
 
        }
    }
    
    //对数据源数组进行排序
    NSMutableArray *regionArr=[NSMutableArray array];;
  
    for (int i=0; i<_dataArr.count; i++) {
        
        NSInteger smallCount = 0; NSInteger nindex = 0;

        for (int j=0; j<_dataArr.count; j++) {
            NSMutableArray *sectionArr=_dataArr[j];
            KondonPhotoModel *model=sectionArr[0];
            
            NSArray *timstringArr=[model.timeString componentsSeparatedByString:@"-"];
            
            NSMutableString *mutbleString=[NSMutableString string];
            
            [mutbleString appendString:timstringArr[1]];
            [mutbleString appendString:timstringArr[0]];
            NSInteger count1=[mutbleString integerValue];
            
            if (count1>smallCount) {
                smallCount=count1;
                nindex=j;
            }
        }
        NSMutableArray *sectionArr=_dataArr[nindex];
        [regionArr addObject:sectionArr];
        [_dataArr removeObject:sectionArr];
        
    }
    
    if (_dataArr.count>0) {
        
        [regionArr addObject:_dataArr.lastObject];
    }
    _dataArr=nil;
//
    _dataArr=[NSMutableArray arrayWithArray:regionArr];
    
    self.photoCollection.frame=CGRectMake(0, 64, ScreenW, ScreenH-108);
    [self.view addSubview:self.photoCollection];
    self.photoCollection.delegate=self;
    self.photoCollection.dataSource=self;
    [self.view addSubview:self.headerView];
    [_sharedButton setImage:[UIImage imageNamed:@"EX_App_VIEWER_DOWNLOAD"] forState:UIControlStateNormal];
    NSAttributedString *str1=[[NSAttributedString alloc]initWithString:@"DOWNLOAD" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [_sharedButton setAttributedTitle:str1 forState:UIControlStateNormal];
    
    [_sharedButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 15, -80)];
    NSLog(@"%@",dic.description);
    
}

#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

#pragma mark --- 下载事件

-(void)downloadbuttonDidClicked{
    
    if (self.selectedArr.count==0&&_hasShowingBigPic==NO) {
        [SVProgressHUD showErrorWithStatus:@"PLEASE SELECT THE MEDIA"];
        return;
    }
    if (self.selectedArr.count==0&&_hasShowingBigPic==YES) {
        
        [self.selectedArr addObject:selectedindex];
        
    }
    
    if ([self.sharedButton.currentAttributedTitle.string isEqualToString:@"SHARE"]) {
        
        if (_selectedArr.count>1) {
            [SVProgressHUD showErrorWithStatus:@"YOU CAN ONLY SHARE ONE FILE AT THE SAME TIME"];
            return ;
        }
        
        //做分享
        //

            NSIndexPath *index = _selectedArr[0];
            NSMutableArray *sectionArr=_localArr[index.section];
            KondonPhotoModel *model=sectionArr[index.row];
            _selectedmodel=model;
        NSURL *pathUrl;
        if (model.isVideo==YES) {
            
            pathUrl = model.pathUrl;
        }else{
            pathUrl = [[NSURL alloc]initFileURLWithPath:model.pathUrl.description];
        }
        
        
            // Initialize Document Interaction Controller
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:pathUrl];
            
            // Configure Document Interaction Controller
            [self.documentInteractionController setDelegate:self];
            
            // Present Open In Menu
            [self.documentInteractionController presentOptionsMenuFromRect:[self.sharedButton frame] inView:self.view animated:YES];

        
        [_selectedArr removeAllObjects];
        [self cleanSomeSelectedPhoto];
        
        return;
    }

    //下载提示
    [_downloadAlertView removeFromSuperview];
    
    _downloadAlertView = [[UIAlertView alloc]initWithTitle:@"WARNING" message:@" Download selected media? These media will save to your library"delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [_downloadAlertView show];
    
    totalItem=0;
    DownloadingIndex=0;
    
//    [SVProgressHUD showWithStatus:@"Downloading"];
   
}
#pragma MARK --- 清楚选中项目之后清楚选中符号
-(void)cleanSomeSelectedPhoto{
    
    NSInteger count = _loadDataFormNet==YES?_dataArr.count:_localArr.count;
    for (int i=0; i<count; i++) {
        
        NSMutableArray *sectionArr=_loadDataFormNet==YES?_dataArr[i]:_localArr[i];
        for (int j=0; j<sectionArr.count; j++) {
            
            NSIndexPath *index = [NSIndexPath indexPathForItem:j inSection:i];
            //   NSIndexPath *index=[NSIndexPath indexPathForRow:j inSection:i];
            
            KondorCollectionCell *cell;
            if (_loadDataFormNet==YES) {
                
               cell = (KondorCollectionCell *)[self.photoCollection cellForItemAtIndexPath:index];
            }else{
                cell = (KondorCollectionCell *)[self.localCollection cellForItemAtIndexPath:index];
            }
            
            if (cell.hasSelected==YES) {
                [cell.MYmaskView removeFromSuperview];
                cell.hasSelected=NO;
                
            }
        }
        
    }
    
}



#pragma mark -- 创建进度视图
-(void)creatProgressViewWithTitle:(NSString *)title{

    [self.view addSubview:self.progressArrView];
    
    _progressNameLabel.text=title;
    
    _successPercentLabel.text=[NSString stringWithFormat:@"0/%zd",_selectedArr.count];
    [_deleteCancelBtn removeTarget:self action:@selector(cancelDeletedBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [_deleteCancelBtn removeTarget:self action:@selector(cancelDownloadBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    if ([title isEqualToString:@"DELETING"]) {
        
        [_deleteCancelBtn addTarget:self action:@selector(cancelDeletedBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }else{
        
         [_deleteCancelBtn addTarget:self action:@selector(cancelDownloadBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

#pragma mark --- 取消下载
-(void)cancelDownloadBtnDidClicked{
    
    
    for (KondorSession *konsession in _sizeModelArr) {
        if (konsession.session!=nil) {
            
            [konsession.session invalidateAndCancel];
        }
    }

    [_sizeModelArr removeAllObjects];
   
    [_progressArrView removeFromSuperview];
    _progressArrView=nil;
    
}


#pragma mark -- 下载代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    NSString *index=session.sessionDescription;
    NSInteger j=[index integerValue];
    if (j>=self.sizeModelArr.count) {
        return;
    }
    
    KondorSession *kondorsession=self.sizeModelArr[j];
    KondonPhotoModel *model=kondorsession.model;
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    NSDate *date=[NSDate date];
    NSString *dateFormat=@"hh-mm-ss";
    NSDateFormatter *dFormate=[[NSDateFormatter alloc] init];
    dFormate.dateFormat=dateFormat;
    NSString *currenttimeString=[dFormate stringFromDate:date];
    
    totalItem++;
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _successPercentLabel.text=[NSString stringWithFormat:@"%zd/%zd",totalItem,_selectedArr.count];
//        _progressView.progress=percent;
    });
   
    
    if (kondorsession.isVideo==YES) {
        
        NSString *nameString=[NSString stringWithFormat:@"%@$%@$%@",model.timeString,currenttimeString,model.pathUrl.description.lastPathComponent];
        
        NSString *pathstring=[NSString stringWithFormat:@"%@/%@",sanbox,nameString];
        NSLog(@"fullPath:%@",pathstring);
        [data writeToFile:pathstring atomically:YES];
        
        UISaveVideoAtPathToSavedPhotosAlbum(pathstring, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
    }else{
        
        NSString *nameString=[NSString stringWithFormat:@"%@$%@$%@",model.timeString,currenttimeString,model.pathUrl.description.lastPathComponent];
        
                        NSString *pathstring=[NSString stringWithFormat:@"%@/%@",sanbox,nameString];
                        [[NSFileManager defaultManager] removeItemAtPath:pathstring error:nil];
                        [data writeToFile:pathstring atomically:YES];
        
                            UIImage *dataImg=[UIImage imageWithData:data];
                            NSData *jgpdata=UIImageJPEGRepresentation(dataImg, 0.2);
                            UIImage* nimage = [UIImage imageWithData:jgpdata];// myImage为自己的图片
        
                            NSData* imageData =  UIImagePNGRepresentation(nimage);
                            
                            UIImage* newImage = [UIImage imageWithData:imageData];
                            
                            UIImageWriteToSavedPhotosAlbum(newImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        
    }
    if (totalItem==_selectedArr.count) {
        totalItem=0;
        totalSize=0;
        [self.sizeModelArr removeAllObjects];
        
        [SVProgressHUD showSuccessWithStatus:@"Download Successful"];
        [self.localArr removeAllObjects];
        for (NSIndexPath *index in _selectedArr) {
            KondorCollectionCell *cell =(KondorCollectionCell *)[_photoCollection cellForItemAtIndexPath:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                cell.hasSelected=NO;
                [cell.MYmaskView removeFromSuperview];
            });
        }
        [_sizeModelArr removeAllObjects];
        [self.selectedArr removeAllObjects];
        _localNeedReFresh=YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_progressArrView removeFromSuperview];
            _progressArrView=nil;
        });
    }
    
    if (++DownloadingIndex<_selectedArr.count) {
        [self beginDownLoadMediaWith:DownloadingIndex];
        
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    CGFloat percent = (totalBytesWritten*1.0)/(totalBytesExpectedToWrite*1.0);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _progressView.progress=percent;
        });
    
    NSLog(@"-------%.2f-------name%@---",percent,[NSThread currentThread]);
}


#pragma mark -- 保存视图提示
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo { //
    
    if(error!=nil){
       
        [SVProgressHUD showErrorWithStatus:@"ERROR OF SAVE"];
    }else{
      
//        [SVProgressHUD showErrorWithStatus:@"save success"];
    }
    
    
}
-(void)video:(NSData *)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo{
    if(error!=nil){
        [SVProgressHUD showErrorWithStatus:@"ERROR OF SAVE"];
    }else{
//        [SVProgressHUD showErrorWithStatus:@"save success"];
    }
    
}

#pragma mark -- 取消删除按钮点击
-(void)cancelDeletedBtnDidClicked{
    
    [_selectedArr removeAllObjects];
    [_sizeModelArr removeAllObjects];
    [_progressArrView removeFromSuperview];
    [_photoCollection removeFromSuperview];
    _progressArrView=nil;
    _photoCollection=nil;
    //重新加载
//    [self.photoCollection reloadData];
    [self.dataArr removeAllObjects];
    
    [self loadDateFromNetOrApp];
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
//    
//}

-(void)beginDownLoadMediaWith:(NSInteger)i{
    NSIndexPath *index = _selectedArr[i];
    NSInteger j = [_selectedArr indexOfObject:index];
    
    NSMutableArray *sectionArr=_dataArr[index.section];
    KondonPhotoModel *model=sectionArr[index.row];
    _selectedmodel=model;
    
    KondorSession *kondorsession = [[KondorSession alloc]init];
    kondorsession.model=model;
    kondorsession.isVideo = model.isVideo?YES:NO;
    [self.sizeModelArr addObject:kondorsession];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:model.pathUrl];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:_Downqueue];
    session.sessionDescription=[NSString stringWithFormat:@"%zd",j];
    kondorsession.session=session;
    kondorsession.sessionDescription=[NSString stringWithFormat:@"%zd",j];
   
    self.task = [session downloadTaskWithRequest:request];
    
    [self.task resume];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (alertView==_downloadAlertView) {
         if (buttonIndex!=0) {
        [self creatProgressViewWithTitle:@"DOWNLOADING"];
             
             [self beginDownLoadMediaWith:0];
            
         }
        return ;
    }else{
        

    if (buttonIndex!=0) {
       
        if (_loadDataFormNet==YES) {
            
            totalItem=0;
            deleteErrorItem=0;
            [successArr removeAllObjects];
            successArr=[NSMutableArray array];
            
            
            [[SDWebImageManager sharedManager] cancelAll];
            
            [self creatProgressViewWithTitle:@"DELETING"];
            NSInteger i=0;
            for (NSIndexPath *index1 in _selectedArr) {
                i=i+2;
                NSMutableArray *sectionArr=_dataArr[index1.section];
                KondonPhotoModel *model=sectionArr[index1.row];
                
                NSString *oldstring=model.pathUrl.description.lastPathComponent;
                
                NSString*newString=[NSString stringWithFormat:@"%@/%@",@"/tmp/SD0/DCIM/100MEDIA",oldstring];
                
                NSLog(@"url =  %@",newString);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    deletingItem=model;
                    [[CameraTool shareTool] deleteFiles:newString];
                });
                
            }
            
        }else{
            [SVProgressHUD show];
            NSInteger tim = 0;
            for (NSIndexPath *index in _selectedArr) {
                tim++;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*tim* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    NSMutableArray *sectionArr=_localArr[index.section];
                    KondonPhotoModel *model=sectionArr[index.row];
                    
                    if (model.isVideo==YES) {
                        [[NSFileManager defaultManager] removeItemAtURL:model.pathUrl error:nil];
                    }else{
                        
                        [[NSFileManager defaultManager] removeItemAtPath:model.pathUrl.description error:nil];
                    }
                    [sectionArr removeObjectAtIndex:index.row];
                  
                });
                
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(tim*0.6 * NSEC_PER_SEC+1)), dispatch_get_main_queue(), ^{
                
                    [SVProgressHUD dismiss];
                    [_selectedArr removeAllObjects];
                    [self cleanSomeSelectedPhoto];
                    [_cellDic removeAllObjects];
                
                    [self.localArr removeAllObjects];
                    _localCollection=nil;
                    [self loadDateFromNetOrApp];
            });
            
        }
        
        return;
        
    }
        
    }
    
}


#pragma mark --- 删除事件响应
//删除按钮点击事件
-(void)deleteButtonDidClicked{
    
    if (_selectedArr.count==0&&_hasShowingBigPic==NO) {
        [SVProgressHUD showErrorWithStatus:@"PLEASE SELECT THE MEDIA"];
        return;
    }
    
    if (_selectedArr.count==0&&_hasShowingBigPic==YES) {
        
        [SVProgressHUD showErrorWithStatus:@"PLEASE GO BACK TO DELETE"];
        return ;
    }
    
    //删除提示
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"WARNING" message:@" Delete selected media? This action cannot be undone"delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
    
}

#pragma mark -- 删除通知回调
-(void)deleteFileCompletion:(NSNotification *)noti{
    totalItem++;

    if (noti.object!=nil) {
      deleteErrorItem++;
        
        
    }else{
//        NSArray *viewArr=self.progressArrView.subviews;
      
        CGFloat  progress = totalItem*1.0/_selectedArr.count*1.0 ;
        _progressView.progress = progress;
        _successPercentLabel.text = [NSString stringWithFormat:@"%zd/%zd",totalItem,_selectedArr.count];
        
        [successArr addObject:deletingItem];
    }
    if (totalItem==_selectedArr.count) {
        
        if (deleteErrorItem>0) {
            NSString *status=[NSString stringWithFormat:@"%zd ITEM ERROR",deleteErrorItem];
            [SVProgressHUD showErrorWithStatus:status];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"Delete Successful"];
        }

        totalItem=0;
//        for (NSIndexPath *index2 in _selectedArr) {
//            NSMutableArray *sectionArr=_dataArr[index2.section];
//            KondonPhotoModel *model=sectionArr[index2.row];
//            [sectionArr removeObject:model];
//            if (sectionArr.count==0) {
//                [_dataArr removeObject:sectionArr];
//            }
//            KondorCollectionCell *cell = (KondorCollectionCell *)[self.photoCollection cellForItemAtIndexPath:index2];
//            cell.hasSelected=NO;
//        
//            [cell.MYmaskView removeFromSuperview];
//            
//        }
        // 删除成功的那些index
        NSMutableArray *sucessIndexArr=[NSMutableArray array];
        NSInteger totalitemCount =0;
        for (int i=0; i<_dataArr.count; i++) {
            NSMutableArray *sectionArr=_dataArr[i];
            
            for (int j=0; j<sectionArr.count; j++) {
                totalitemCount++;
                if ([successArr containsObject:sectionArr[j]]) {
                    NSIndexPath *index3=[NSIndexPath indexPathForItem:j inSection:i];
                    [sucessIndexArr addObject:index3];
                }
                
            }
        }
        
    
        // section数组删除需要删除的
        for (NSMutableArray *sectionArr in _dataArr) {
            
            NSInteger j = [_dataArr indexOfObject:sectionArr];
            NSMutableIndexSet *deleteSet = [[NSMutableIndexSet alloc]init];
            
            for (NSIndexPath *index in sucessIndexArr) {
                
                if (index.section==j) {
                    
                    [deleteSet addIndex:index.row];
                    
                }
                
            }
            [sectionArr removeObjectsAtIndexes:deleteSet];
        }
        
        //移除为空的section
        NSMutableIndexSet *sectiondeleteSet = [[NSMutableIndexSet alloc]init];
        BOOL needRemoveSection = NO;
        for (NSMutableArray *sectionArr in _dataArr) {
            if(sectionArr.count==0){
                needRemoveSection=YES;
                NSInteger j = [_dataArr indexOfObject:sectionArr];
                [sectiondeleteSet addIndex:j];
            }
        }
        [_dataArr removeObjectsAtIndexes:sectiondeleteSet];
       
        
        //移除选择
         resfreshTimes++;
        [_selectedArr removeAllObjects];
        [self cleanSomeSelectedPhoto];
        [_cellDic removeAllObjects];
        
        [self.progressArrView removeFromSuperview];
        _progressArrView=nil;
        [_sizeModelArr removeAllObjects];
        //  做移除动画
        
        if (needRemoveSection==YES) {
            [self.dataArr removeAllObjects];
            
            [_photoCollection removeFromSuperview];
            _photoCollection=nil;
            [self loadDateFromNetOrApp];
            return;
        }
        
        
        if(sucessIndexArr.count==totalitemCount){
            
            [_photoCollection removeFromSuperview];
        }else{
             NSArray *arr=sucessIndexArr.copy;
            [_photoCollection deleteItemsAtIndexPaths:arr];
 
        }
        
    }
    NSLog(@"删除成功啦");
}

#pragma mark ---- 切换本地或者相机
-(void)locationButtonDidClicked{
    [[SDWebImageManager sharedManager] cancelAll];
    
    [self.view addSubview:self.maskView];
    self.choseView.frame=CGRectMake((ScreenW-300)*0.5, ScreenH, 300, 140);
    [self.view addSubview:self.choseView];
    [UIView animateWithDuration:0.5 animations:^{
        
        _choseView.frame=CGRectMake((ScreenW-300)*0.5, (ScreenH-140)*0.5, 300, 140);
    }];
    
}
// 选择视图的代理方法
-(void)chooseViewButtonDidClicked:(UIButton *)button{
    
    [_choseView removeFromSuperview];
    if (button.tag==2) {
        return;
    }else if(button.tag==1){
        
        if (_loadDataFormNet==YES) {
            return;
        }else{
            
            _titleLabel.text=@"CAMERA LIBRARY";
            UITabBarItem *item= self.navigationController.tabBarItem;
            
            [item setSelectedImage:[UIImage imageNamed:@"EX_App_VIEWER_CAMERA"]];
            [item setImage:[UIImage imageNamed:@"EX_App_VIEWER_CAMERA"]];
            
        
            
            [_sharedButton setImage:[UIImage imageNamed:@"EX_App_VIEWER_DOWNLOAD"] forState:UIControlStateNormal];
            NSAttributedString *str1=[[NSAttributedString alloc]initWithString:@"DOWNLOAD" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            [_sharedButton setAttributedTitle:str1 forState:UIControlStateNormal];
            
            [_sharedButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 15, -80)];
            self.navigationController.tabBarItem.title=@"CAMERA";
            _loadDataFormNet=YES;
            [self loadDateFromNetOrApp];
        }
        
    }else if(button.tag==0){
        if (_loadDataFormNet==NO) {
            
            return;
        }else{
            _titleLabel.text=@"DEVICE LIBRARY";
            [_sharedButton setTitleEdgeInsets:UIEdgeInsetsMake(25, 0, 0, 0)];
            NSAttributedString *str1=[[NSAttributedString alloc]initWithString:@"SHARE" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            [_sharedButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 15, -60)];
            [_sharedButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
            [_sharedButton setAttributedTitle:str1 forState:UIControlStateNormal];
            UITabBarItem *item= self.navigationController.tabBarItem;
            [item setSelectedImage:[UIImage imageNamed:@"EX_App_MAIN MENU_VIEWER"]];
            [item setImage:[UIImage imageNamed:@"EX_App_MAIN MENU_VIEWER"]];
  
            
            
            
            self.navigationController.tabBarItem.title=@"LIBRARY";
            _loadDataFormNet=NO;
            [self loadDateFromNetOrApp];
        }
    }
   [self.view addSubview:_headerView];
    
    
    NSInteger count = 0;   CGFloat padding = 0.0;
    for (UIView *bview in [self.navigationController.tabBarController.tabBar subviews]) {
        
        if ([bview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            
            if (count==0) {
                count++;
            
            if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
                NSLog(@"----shishenme -- %@",[UIDevice currentDevice].model);
                
                padding = -20;
                
            }
               
                self.line1.frame = CGRectMake(0-2+padding, 2, 2, bview.bounds.size.height);
            
            self.line1.backgroundColor=[UIColor whiteColor];
            [bview addSubview:self.line1];
            }
        }
        
        
    }
}
#pragma mark -- 移除选择视图
-(void)removeMaskVIewFromView{
    [_choseView removeFromSuperview];
    [_maskView removeFromSuperview];
}


-(NSArray *) getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSArray *fileList = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil]
                         pathsMatchingExtensions:[NSArray arrayWithObject:type]];
    return fileList;
}


-(UICollectionView *)photoCollection
{
    if (_photoCollection==nil) {
        
        UICollectionViewFlowLayout *flowlayout=[[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize=CGSizeMake(80, 80);
        flowlayout.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
        flowlayout.minimumLineSpacing=10;
        flowlayout.minimumInteritemSpacing=10;
//        flowlayout.sectionHeadersPinToVisibleBounds=YES;
        
        _photoCollection=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, ScreenW, ScreenH-108) collectionViewLayout:flowlayout];
     
        [_photoCollection registerClass:[KondorSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        _photoCollection.contentInset=UIEdgeInsetsMake(44, 0, 0, 0);
        
        
        _photoCollection.backgroundColor=[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
     
    }
    return _photoCollection;
}

-(UICollectionView *)localCollection
{
    if (_localCollection==nil) {
        
        UICollectionViewFlowLayout *flowlayout=[[UICollectionViewFlowLayout alloc]init];
        flowlayout.itemSize=CGSizeMake(80, 80);
        flowlayout.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
        flowlayout.minimumLineSpacing=10;
        flowlayout.minimumInteritemSpacing=10;
        //        flowlayout.sectionHeadersPinToVisibleBounds=YES;
        
        _localCollection=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, ScreenW, ScreenH-108) collectionViewLayout:flowlayout];
        
        [_localCollection registerClass:[KondorSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        _localCollection.contentInset=UIEdgeInsetsMake(44, 0, 0, 0);
        
        _localCollection.backgroundColor=[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
        
    }
    return _localCollection;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
 
//    [[SDWebImageManager sharedManager] ]
}


-(void)firstbuttonDidClick{
    
    if (_loadDataFormNet==YES) {
        return;
    }
    
  [self.navigationController pushViewController:self.camerVc animated:YES];
    
}

-(NSMutableArray *)dataArr
{
    if (_dataArr==nil) {
        _dataArr=[NSMutableArray array];
    }
    return _dataArr;
}


-(NSMutableArray *)selectedArr
{
    if (_selectedArr==nil) {
        _selectedArr=[NSMutableArray array];
    }
    return _selectedArr;
}

-(bigSizeImageView *)bigImgView
{
    if (_bigImgView==nil) {
           _bigImgView=[[bigSizeImageView alloc]initWithFrame:CGRectMake(0, 64+44, ScreenW, ScreenH-110-44)];
    }
    return _bigImgView;
}

-(UIButton *)changeModelbtn
{
    if (_changeModelbtn==nil) {
        _changeModelbtn=[[UIButton alloc]init];
    }
    return _changeModelbtn;
}
-(KondorViewVC *)camerVc
{
    if (_camerVc==nil) {
        _camerVc=[[KondorViewVC alloc] init];
        _camerVc.loadDataFormNet=YES;
    }
    return _camerVc;
}

-(NSMutableArray *)localFileArr
{
    if (_localFileArr==nil) {
        _localFileArr=[NSMutableArray array];
    }
    
    return _localFileArr;
}

-(UIImageView *)tipsView
{
    if (_tipsView==nil) {
        _tipsView=[[UIImageView alloc]init];
    }
    return _tipsView;
}
-(chooseDeviceView *)choseView{
    
    if (_choseView==nil) {
        _choseView=[[NSBundle mainBundle] loadNibNamed:@"chooseDeviceView" owner:self options:nil].lastObject;
        _choseView.layer.cornerRadius=10;
        _choseView.layer.masksToBounds=YES;
        _choseView.layer.borderColor=[UIColor colorWithRed:233.0/255.0 green:73.0/255.0 blue:74.0/255.0 alpha:1].CGColor;
        _choseView.layer.borderWidth=2.0;
        _choseView.delegate=self;
    }
    return _choseView;
}

-(UIImageView *)maskView
{
    if (_maskView==nil) {
        _maskView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
        _maskView.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeMaskVIewFromView)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}
-(NSMutableArray *)sizeModelArr
{
 
    if (_sizeModelArr==nil) {
        _sizeModelArr=[NSMutableArray array];
    }
    return _sizeModelArr;
}
-(NSMutableArray *)localArr{
    
    if (_localArr==nil) {
        _localArr=[NSMutableArray array];
    }
    return _localArr;
}



-(UIView *)progressArrView
{
    if (_progressArrView==nil) {
        _progressArrView=[[UIView alloc]init];
        CGFloat progressheight=2*40+20*2;
        //    if (_selectedArr.count>10) {
        //        progressheight=2*40+20*10;
        //    }else{
        //        progressheight=2*40+20*_selectedArr.count;
        //    }
        
        _progressArrView.frame=CGRectMake((ScreenW-300)*0.5, (ScreenH-20*_selectedArr.count)*0.5, 300, progressheight);
        _progressArrView.backgroundColor=[UIColor darkGrayColor];
        _progressArrView.layer.cornerRadius=5;
        _progressArrView.layer.masksToBounds=YES;
        // 招牌
        _progressNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
        _progressNameLabel.textAlignment=NSTextAlignmentCenter;
        _progressNameLabel.textColor=[UIColor lightGrayColor];
        _progressNameLabel.font=[UIFont systemFontOfSize:18];
        [_progressArrView addSubview:_progressNameLabel];
        
        _progressView=[[UIProgressView alloc]initWithFrame:CGRectMake(50, 50, 200, 20)];
        _progressView.transform = CGAffineTransformMakeScale(1.0f,3.0f);
        _progressView.progressTintColor=[UIColor colorWithRed:167/255.0 green:80/255.0 blue:86/255.0 alpha:1];
        _progressView.trackTintColor=[UIColor whiteColor];
        [_progressArrView addSubview:_progressView];
        
        //显示完成度的label
        _successPercentLabel=[[UILabel alloc]initWithFrame:CGRectMake(250, 40, 50, 20)];
        _successPercentLabel.font=[UIFont systemFontOfSize:15];
        _successPercentLabel.textColor=[UIColor whiteColor];
        _successPercentLabel.textAlignment=NSTextAlignmentCenter;
        [_progressArrView addSubview:_successPercentLabel];
        
        //    self.progressArrView.backgroundColor=RandomColor;
        
        _deleteCancelBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, progressheight-40, 300, 40)];
        _deleteCancelBtn.backgroundColor=[UIColor redColor];
        [_deleteCancelBtn setTitle:@"CANCEL" forState:UIControlStateNormal];
        _progressArrView.layer.borderColor=[UIColor colorWithRed:233.0/255.0 green:73.0/255.0 blue:74.0/255.0 alpha:1].CGColor;
        _progressArrView.layer.borderWidth=2.0;
        
        [_progressArrView addSubview:_deleteCancelBtn];
        
    }
    return _progressArrView;
}

-(UIImageView *)line1
{
    if (_line1==nil) {
        _line1=[[UIImageView alloc]init];
    }
    return _line1;
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [[SDWebImageManager sharedManager] cancelAll];

    NSLog(@"444444444memory");
}

-(NSMutableArray *)downTaskArr
{
    if (_downTaskArr==nil) {
        _downTaskArr=[NSMutableArray array];
    }
    return _downTaskArr;
}


@end










