//
//  HAAccountTableViewCell.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/13.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAAccountTableViewCell.h"

@implementation HAAccountTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


+(instancetype)accountCellWithtableView:(UITableView *)tableView{
    
    HAAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountTableViewCell"];
    if (cell==nil) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"HAAccountTableViewCell" owner:self options:nil].lastObject;
    }
    return cell;
    
}

-(void)setMyindex:(NSIndexPath *)myindex
{
    _myindex=myindex;
    
    if (myindex.section==0) {
        switch (myindex.row) {
            case 0:
                _tipsLabel.hidden=YES;
                _iconImage.image = [UIImage imageNamed:@"头像ICON"];
                _nameLabel.text=@"头像";
                _advaerImage.image = [UIImage imageNamed:@"酒店上传头像"];
                
                break;
            case 1:
                _tipsLabel.text=@"亚朵酒店-总店";
                _iconImage.image = [UIImage imageNamed:@"酒店-icon"];
                _nameLabel.text=@"酒店名称";
                _advaerImage.hidden=YES;
                _backArrow.hidden=YES;
                
                break;
            case 2:
                _tipsLabel.text=@"深圳市深南大道100号";
                _iconImage.image = [UIImage imageNamed:@"位置-icon"];
                _nameLabel.text=@"头像";
                _advaerImage.hidden=YES;
                _backArrow.hidden=YES;
                break;
            case 3:
                _tipsLabel.text=@"四星酒店";
                _iconImage.image = [UIImage imageNamed:@"酒店星级"];
                _nameLabel.text=@"头像";
                _advaerImage.hidden=YES;
                _backArrow.hidden=YES;
                break;
                
            default:
                break;
        }
    }else{
        switch (myindex.row) {
            case 0:
                _tipsLabel.text=@"张经理";
                _iconImage.image = [UIImage imageNamed:@"联系人icon"];
                _nameLabel.text=@"联系人";
                _advaerImage.hidden=YES;
                
                break;
            case 1:
                _tipsLabel.text=@"13658745874";
                _iconImage.image = [UIImage imageNamed:@"电话icon"];
                _nameLabel.text=@"联系电话";
                _advaerImage.hidden=YES;
                
                break;
            case 2:
                _tipsLabel.text=@"13658745874@qq.com";
                _iconImage.image = [UIImage imageNamed:@"邮箱icon"];
                _nameLabel.text=@"邮箱";
                _advaerImage.hidden=YES;
                
                break;
            case 3:
                _tipsLabel.text=@"已经绑定(可用微信登录)";
                _iconImage.image = [UIImage imageNamed:@"微信icon"];
                _nameLabel.text=@"绑定微信";
                _advaerImage.hidden=YES;
                
                break;
                
            default:
                break;
        }
 
    }
 
    
}



@end
