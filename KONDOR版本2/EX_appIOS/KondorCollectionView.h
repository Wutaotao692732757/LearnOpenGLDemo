//
//  KondorCollectionView.h
//  EX_appIOS
//
//  Created by mac_w on 2016/11/12.
//  Copyright © 2016年 aee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KondorCollectionView : UICollectionView
@property(nonatomic,strong)NSMutableArray *dataArr;

@property(nonatomic,assign)BOOL loadFromNet;
@end
