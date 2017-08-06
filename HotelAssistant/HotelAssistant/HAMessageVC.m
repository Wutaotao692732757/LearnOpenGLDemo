//
//  HAMessageVC.m
//  HotelAssistant
//
//  Created by 伍陶陶 on 2017/8/4.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAMessageVC.h"
#import "HAMessageCell.h"
#import "HAOtherMessageCell.h"

@interface HAMessageVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

@property (nonatomic,assign) BOOL isOtherMessage;

@end

@implementation HAMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    self.view.backgroundColor=[UIColor greenColor];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _isOtherMessage?90:264;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_isOtherMessage==YES) {
    
        
        HAOtherMessageCell *cell = [HAOtherMessageCell otherMessageCellWithTableView:tableView];
        
        return cell;
        
    }
        
    HAMessageCell *cell = [HAMessageCell initMessageCellWithTableView:tableView];
    
    
    
    
    
    
    return cell;
}

- (IBAction)orderMessageBtnDidClicked:(id)sender {

    _isOtherMessage = NO;
    [self.messageTableView reloadData];

}

- (IBAction)otherMessageBtnDidClicked:(id)sender {
    
    
    _isOtherMessage=YES;
    [self.messageTableView reloadData];
    
}



@end
