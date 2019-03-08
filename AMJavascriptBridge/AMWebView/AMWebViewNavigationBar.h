//
//  AMWebViewNavigationBar.m
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMWebViewNavigationBar : UIView

/**
 导航栏初始化

 @return 导航栏实例
 */
+ (instancetype)navigationBar;

/**
 设置导航栏右边按钮

 @param buttons 按钮数组
 */
- (void)setRightButtons:(NSArray <UIButton *> *)buttons;

/**
 设置导航栏左边按钮

 @param buttons 按钮数组
 */
- (void)setLeftButtons:(NSArray <UIButton *> *)buttons;

@property (strong, nonatomic) UIColor *titleColor;

@property (copy, nonatomic) NSString *title;

/**
 标题按钮
 */
@property (strong, nonatomic) UIButton *titleButton;

/**
 返回按钮
 */
@property (strong, nonatomic) UIButton *backButton;

@end
