//
//  AMWebViewController.h
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "AMWebProgressView.h"
#import "AMWebViewNavigationBar.h"

@class AMWebViewController;

#pragma mark - AMWebViewDelegate

/**
 WKWebView的映射协议方法
 */
@protocol AMWebViewDelegate <NSObject>

@optional

/// 开始加载(a main frame navigation starts)
- (void)webView:(AMWebViewController *)webViewController didStartLoadingURL:(NSURL *)URL;

/// 加载完成(a main frame navigation completes)
- (void)webView:(AMWebViewController *)webViewController didFinishLoadingURL:(NSURL *)URL;

/// 加载失败(an error occurs while starting to load data for the main frame / an error occurs during a committed main frame navigation.)
- (void)webView:(AMWebViewController *)webViewController didFailToLoadURL:(NSURL *)URL error:(NSError *)error;

@end

@interface AMWebViewController : UIViewController <WKNavigationDelegate, WKUIDelegate, UIWebViewDelegate>

#pragma mark - Initialize

/**
 实例方法初始化
 */
- (id)initWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

/**
 类方法初始化
 */
+ (instancetype)webView;
+ (instancetype)webViewWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

#pragma mark - Property

@property (nonatomic, weak) id<AMWebViewDelegate> delegate;

/**
 是否使用WK
 */
@property (nonatomic, assign) BOOL isWK;

/// UI相关
/**
 当前的 WKWebView
 */
@property (nonatomic, strong) WKWebView *wkWebView;

/**
 当前的 UIWebView
 */
@property (nonatomic, strong) UIWebView *uiWebView;

/**
 当前 WKWebView 加载失败的 URL
 */
@property (nonatomic, strong, readonly) NSURL *failUrl;

/**
 导航栏标题
 */
@property (nonatomic, copy) NSString *barTitle;

/**
 导航栏标题颜色
 */
@property (nonatomic, copy) UIColor *barTitleColor;

/**
 自定义导航栏的 barTintColor
 */
@property (nonatomic, strong) UIColor *barTintColor;

/**
 导航栏标题按钮
 */
@property (nonatomic, strong) UIButton *titleButton;

/**
 左边返回按钮
 */
@property (nonatomic, strong) UIButton *leftButton;

/**
 右边按钮 默认隐藏
 */
@property (nonatomic, strong) UIButton *rightButton;

/**
 是否显示导航栏
 */
@property (nonatomic, assign) BOOL showNavigationBar;

/**
 若没有 navigationController 则显示自定义导航栏在 viewDidLoad 之后被创建
 */
@property (nonatomic, strong, readonly) AMWebViewNavigationBar *customNavigationBar;

/**
 默认的进度条添加在 navigationController 上
 若没有 navigationController
 则加载咋 CustomHeaderView 上，也可以自己定义实现
 */
@property (nonatomic, strong, readonly) AMWebProgressView *progressView;

/**
 是否开启伪进度条
 */
@property (nonatomic, assign) BOOL fakeProgress;

/**
 默认的空白试图，可以自定义实现
 */
@property (nonatomic, strong) UIView *refreshView;

/**
 是否在导航栏显示 URL
 */
@property (nonatomic, assign) BOOL showsURLInNavigationBar;

/**
 是否显示网页的 title 为标题
 */
@property (nonatomic, assign) BOOL showsPageTitleInNavigationBar;


#pragma mark - Public Method

- (void)updateTitle;

- (void)loadURL:(NSURL *)URL;

- (void)loadURLString:(NSString *)URLString;

- (void)loadHTMLString:(NSString *)HTMLString;

- (void)loadHTMLString:(NSString *)HTMLString baseURl:(NSURL *)baseUrl;

- (void)loadRequest:(NSURLRequest *)request;

@end
