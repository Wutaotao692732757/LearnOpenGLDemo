//
//  PaintingView.h
//  绘图
//
//  Created by wutaotao on 2017/4/19.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface LYPoint : NSObject

@property (nonatomic , strong) NSNumber* mY;
@property (nonatomic , strong) NSNumber* mX;

@end

@interface PaintingView : UIView

@property(nonatomic,readwrite) CGPoint location;
@property(nonatomic,readwrite) CGPoint previousLocation;

- (void)erase;
- (void)setBrushColorwithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

-(void)paint;
-(void)clearPaint;

@end



