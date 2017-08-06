//
//  HAMyOrderVC.m
//  HotelAssistant
//
//  Created by wutaotao on 2017/8/6.
//  Copyright © 2017年 LIU. All rights reserved.
//

#import "HAMyOrderVC.h"
#import "HAOrderCell.h"


#define  SCREENW  [UIScreen mainScreen].bounds.size.width
#define  SCREENH  [UIScreen mainScreen].bounds.size.height
#define  RandomColor [UIColor colorWithRed: (arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:1]

@interface HAMyOrderVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *totalBtn;

@property (weak, nonatomic) IBOutlet UIButton *doingBtn;
@property (weak, nonatomic) IBOutlet UIButton *successBtn;

@property (weak, nonatomic) IBOutlet UIButton *cancedBtn;
@property (nonatomic,strong) NSMutableArray *btnArr;


@property (weak, nonatomic) IBOutlet UIScrollView *orderScroller;


@end

@implementation HAMyOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.navigationItem.title = @"我的订单";
    
    self.orderScroller.contentSize = CGSizeMake(SCREENW*4, SCREENH-64-44*2);
    self.orderScroller.scrollEnabled = YES;
    self.orderScroller.backgroundColor=[UIColor greenColor];
    
    
    for (int i =0; i<4; i++) {
        
        UITableView *pageTable = [[UITableView alloc]initWithFrame:CGRectMake(i*SCREENW, 0, SCREENW, SCREENH-64-44*2)];
        pageTable.tag = i;
        pageTable.delegate = self;
        pageTable.dataSource = self;
        pageTable.backgroundColor = [UIColor colorWithRed: (arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:1];
        [self.orderScroller addSubview:pageTable];
    }
    
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAOrderCell *cell = [HAOrderCell HAordercellWithtableView:tableView];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 290.0;
}


- (IBAction)selectBtnDidClicked:(id)sender {
    
    for (UIButton *btn in self.btnArr) {
        
        btn.backgroundColor = [UIColor whiteColor] ;
        
        [btn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
    }
    
    
    UIButton *selcBtn = (UIButton *)sender;
    
    selcBtn.backgroundColor = [UIColor colorWithRed:0/255.0 green:172/255.0 blue:200/255.0 alpha:1];
    
    [selcBtn  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    [_orderScroller setContentOffset:CGPointMake(SCREENW*selcBtn.tag, 0) animated:YES];
    
  
    
}

-(NSMutableArray *)btnArr
{
    if (_btnArr==nil) {
        _btnArr = [NSMutableArray array];
        
        [_btnArr addObject:_totalBtn];
        [_btnArr addObject:_doingBtn];
        [_btnArr addObject:_successBtn];
        [_btnArr addObject:_cancedBtn];
  
    }
    return _btnArr;
}


@end
