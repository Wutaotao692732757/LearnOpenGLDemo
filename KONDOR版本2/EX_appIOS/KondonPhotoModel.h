//
//  KondonPhotoModel.h
//  EX_appIOS
//
//  Created by mac_w on 2016/11/12.
//  Copyright © 2016年 aee. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface KondonPhotoModel : NSObject

@property(nonatomic,strong) NSURL *pathUrl;

//是否是视频
@property(nonatomic,assign) BOOL isVideo;

//创建时间
@property(nonatomic,copy) NSString *timeString;

//文件大小
@property(nonatomic,assign)double size;



@end
