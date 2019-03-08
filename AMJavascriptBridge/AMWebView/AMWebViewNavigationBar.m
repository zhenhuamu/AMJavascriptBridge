//
//  AMWebViewNavigationBar.h
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "AMWebViewNavigationBar.h"
#import "NSBundle+AMWebView.h"

#define kIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define kRightButtonTag 1000

#define kLeftButtonTag 1001

@interface AMWebViewNavigationBar ()

@end

@implementation AMWebViewNavigationBar

+ (instancetype)navigationBar {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGRect barFrame = CGRectMake(0, 0, width, kIsiPhoneX ? 88 : 64);
    
    AMWebViewNavigationBar *bar = [[AMWebViewNavigationBar alloc] initWithFrame:barFrame];
    
    bar.backgroundColor = [UIColor whiteColor];
    
    // 默认有一个返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backButtonItemImage = [[UIImage imageWithContentsOfFile:[[NSBundle am_webViewBundle] pathForResource:@"nav_btn_left@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backButton setImage:backButtonItemImage forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(10, kIsiPhoneX ? 44 : 20, 44, 44);
    [bar addSubview:backButton];
    
    bar.backButton = backButton;
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setTitle:@"" forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    titleButton.frame = CGRectMake((width - 100) * 0.5, kIsiPhoneX ? 44 : 20, 100, 44);
    [bar addSubview:titleButton];
    
    bar.titleButton = titleButton;
    
    return bar;
}

- (void)setTitle:(NSString *)title {
    [self.titleButton setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleColor:(UIColor *)titleColor {
    [self.titleButton setTitleColor:titleColor forState:UIControlStateNormal];
}

- (void)setLeftButtons:(NSArray<UIButton *> *)buttons {
    
    for (UIView *subView in self.subviews) {
        if (subView.tag == kLeftButtonTag) {
            [subView removeFromSuperview];
        }
    }
    
    if (buttons.count <= 0) {
        return ;
    }
    
    [self.backButton removeFromSuperview];
    
    CGFloat currentX = 16;
    
    for (int i = 0 ; i < buttons.count ; i ++) {
        
        UIButton *button = buttons[i];
        
        button.tag = kLeftButtonTag;
        
        CGFloat y =  (44 - button.frame.size.height) * 0.5 + kIsiPhoneX ? 44 : 20 ;
        
        CGRect frame = CGRectMake(currentX,
                                  y,
                                  button.frame.size.width,
                                  button.frame.size.height);
        button.frame = frame;
        
        [self addSubview:button];
        
        currentX += button.frame.size.width;
    }
}

- (void)setRightButtons:(NSArray<UIButton *> *)buttons {
    
    for (UIView *subView in self.subviews) {
        if (subView.tag == kRightButtonTag) {
            [subView removeFromSuperview];
        }
    }
    
    if (buttons.count <= 0) {
        return ;
    }
    
    CGFloat currentX = 16;
    
    for (int i = 0 ; i < buttons.count ; i ++) {
        
        UIButton *button = buttons[i];
        
        button.tag = kRightButtonTag;
        
        CGFloat y =  (44 - button.frame.size.height) * 0.5 + kIsiPhoneX ? 44 : 20 ;
        
        CGFloat x = self.frame.size.width - currentX - button.frame.size.width;
        
        CGRect frame = CGRectMake(x,
                                  y,
                                  button.frame.size.width,
                                  button.frame.size.height);
        button.frame = frame;
        
        currentX += button.frame.size.width;
        
        [self addSubview:button];
    }
}


@end
