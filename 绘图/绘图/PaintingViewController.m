//
//  PaintingViewController.m
//  绘图
//
//  Created by wutaotao on 2017/4/19.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "PaintingViewController.h"
#import "PaintingView.h"
#import "SoundEffect.h"


#define kBrightness             1.0
#define kSaturation             0.45

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.5

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0


@interface PaintingViewController (){
    SoundEffect *erasingSound;
    SoundEffect *selectSound;
    CFTimeInterval lastTime;
}

@end

@implementation PaintingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:
                                                                                    [[UIImage imageNamed:@"Red"]       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                    [[UIImage imageNamed:@"Yellow"]    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                    [[UIImage imageNamed:@"Green"]     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                    [[UIImage imageNamed:@"Blue"]      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                    [[UIImage imageNamed:@"Purple"]    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                     nil]];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(rect.origin.x + kLeftMargin, rect.size.height - kPaletteHeight - kTopMargin, rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
    segmentedControl.frame = frame;
    
    [segmentedControl addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.tintColor = [UIColor darkGrayColor];
    segmentedControl.selectedSegmentIndex = 2;
    
    [self.view addSubview:segmentedControl];
    
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kPaletteSize saturation:kSaturation brightness:kBrightness alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
    [(PaintingView *)self.view setBrushColorwithRed:components[0] green:components[1] blue:components[2]];
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    erasingSound = [[SoundEffect alloc]initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
    selectSound = [[SoundEffect alloc]initWithContentsOfFile:[mainBundle pathForResource:@"Select" ofType:@"caf"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eraseView) name:@"shake" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (IBAction)onDraw:(id)sender {
    PaintingView* paintView = (PaintingView *)self.view;
    if (paintView) {
        [paintView paint];
    }
}

- (IBAction)clearDraw:(id)sender {
    
    PaintingView* paintView = (PaintingView *)self.view;
    if (paintView) {
        [paintView clearPaint];
        [self eraseView];
    }
}




- (IBAction)eraseBtnDidClicked:(id)sender {
    
    [self eraseView];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)changeBrushColor:(id)sender{
    
    [selectSound play];
    
    
    CGColorRef color = [UIColor colorWithHue:(CGFloat)[sender selectedSegmentIndex] / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
    [(PaintingView *)self.view setBrushColorwithRed:components[0] green:components[1] blue:components[2]];
    
}

-(void)eraseView{
    
    if (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
        [erasingSound play];
        [(PaintingView *)self.view erase];
        lastTime = CFAbsoluteTimeGetCurrent();
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}


@end



























