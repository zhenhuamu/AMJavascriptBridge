//
//  AMPrivacyPolicy.h
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMPrivacyPolicy : NSObject

/**
 加载网络 URL 隐私政策

 @param url 隐私政策的 url
 @param viewController 从什么控制器跳转
 */
- (void)loadURL:(NSURL *)url fromViewController:(UIViewController *)viewController;

/**
 加载本地 URL 隐私政策
 
 @param file 隐私政策的 file 目录
 @param viewController 从什么控制器跳转
 */
- (void)loadFile:(NSURL *)file fromViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
