//
//  CameraInfoTwelve.h
//  AEE
//
//  Created by aee on 16/6/2.
//  Copyright (c) 2016年 AEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraInfoTwelve : NSObject
@property (nonatomic,strong) NSString *video_quality;  //
@property (nonatomic,strong) NSString *video_resolution;  //
@property (nonatomic,strong) NSString *set_default;   //
@property (nonatomic,strong) NSString *camera_clock; //
//@property (nonatomic,strong) NSString *capture_mode;
//@property (nonatomic,strong) NSString *photo_quality;
@property (nonatomic,strong) NSString *photo_size;  //
@property (nonatomic,strong) NSString *timelapse_photo;   //
@property (nonatomic,strong) NSString *photo_mode;   //
@property (nonatomic,strong) NSString *photo_stamp;  //
@property (nonatomic,strong) NSString *photo_selftimer;//
@property (nonatomic,strong) NSString *photo_tlm;//
@property (nonatomic,strong) NSString *photo_shot_mode;//
@property (nonatomic,strong) NSString *record_mode;//
@property (nonatomic,strong) NSString *video_stamp;//
@property (nonatomic,strong) NSString *video_selftimer;//
@property (nonatomic,strong) NSString *video_fov;//
@property (nonatomic,strong) NSString *video_flip_rotate;//
@property (nonatomic,strong) NSString *video_loop_back;//
@property (nonatomic,strong) NSString *video_standard;//
@property (nonatomic,strong) NSString *key_tone;//
@property (nonatomic,strong) NSString *setup_selflamp;//
@property (nonatomic,strong) NSString *setup_poweroff;//
@property (nonatomic,strong) NSString *language;//
@property (nonatomic,strong) NSString *get_dv_info;//
@property (nonatomic,strong) NSString *get_dv_bat;//
@property (nonatomic,strong) NSString *get_dv_fs;//
@property (nonatomic,strong) NSString *video_time;//

@end
/*
 {"video_quality":"S.Fine"},{"video_resolution":"1920x1080 30P 16:9"},{"set_default":"n/a"},{"camera_clock":"2015-01-01 23:01:33"},{"capture_mode":"precise quality"},{"photo_quality":"S.Fine"},{"photo_size":"12M (4000x3000 4:3)"},{"timelapse_photo":"unknown"},{"photo_mode":"photo_cap_mode_nor"},{"photo_stamp":"photo_stamp_bot"},{"photo_selftimer":"photo_selftimer_03s"},{"photo_tlm":"photo_tlm_02s"},{"photo_shot_mode":"photo_shot_08"},{"record_mode":"record_mode_piv"},{"video_stamp":"date/time"},{"video_selftimer":"video_selftimer_05s"},{"video_fov":"video_fov_wid"},{"video_flip_rotate":"video_flip_rotate_off"},{"video_loop_back":"setup_loop_back_off"},{"video_standard":"NTSC"},{"key_tone":"setup_key_tone_sta"},{"setup_selflamp":"setup_selflamp_on_"},{"setup_poweroff":"setup_poweroff_off"},{"language":"EN"},{"get_dv_info":"AEE S12D Ver:D.EB.30"},{"get_dv_bat":"000"},{"get_dv_fs":"0 30 1129 3 135 0 138"},{"video_time":"00:00:00"}
 */
