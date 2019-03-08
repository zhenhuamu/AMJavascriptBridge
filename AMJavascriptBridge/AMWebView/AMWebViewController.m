//
//  AMWebViewController.m
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//


#import "AMWebViewController.h"
#import "NSBundle+AMWebView.h"

#define AMWebObjIsNilOrNull(_obj)    (((_obj) == nil) || (_obj == (id)kCFNull))
#define AMWebStrIsEmpty(_str)        (AMWebObjIsNilOrNull(_str) || (![(_str) isKindOfClass:[NSString class]]) || ([(_str) isEqualToString:@""]))

#define kAMWebViewIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

static NSString * const kURL = @"URL";
static NSString * const kEstimatedProgress = @"estimatedProgress";

static void *HJWebContext = &HJWebContext;

@interface AMWebViewController ()

@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, strong) NSTimer *fakeProgressTimer;
@property (nonatomic, strong) NSURL *currentUrl;
@property (nonatomic, strong) NSURL *failUrl;
@property (nonatomic, strong) UIColor *originalTintColor;
@property (nonatomic, strong) UIColor *originalBarTintColor;
@property (nonatomic, strong) UIButton *wkTitleButton;
@property (nonatomic, strong, readwrite) AMWebProgressView *progressView;
@property (nonatomic, strong, readwrite) AMWebViewNavigationBar *customNavigationBar;

@end

@implementation AMWebViewController

#pragma mark - Static Initializers

+ (instancetype)webView {
    return [[self class] webViewWithConfiguration:nil];
}

+ (instancetype)webViewWithConfiguration:(WKWebViewConfiguration *)configuration {
    return [[self alloc] initWithConfiguration:configuration];
}

#pragma mark - Initializers

- (instancetype)init {
    return [self initWithConfiguration:nil];
}

- (instancetype)initWithConfiguration:(WKWebViewConfiguration *)configuration {
    self = [super init];
    if (self) {
        
        self.isWK = YES;
        
        if ([WKWebView class]) {
            if (configuration) {
                self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
                self.uiWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
            } else {
                self.wkWebView = [[WKWebView alloc] init];
                self.uiWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
            }
        }
        self.showsURLInNavigationBar = NO;
        self.showsPageTitleInNavigationBar = YES;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isWK) {
        if (self.wkWebView) {
            if (self.navigationController) {
                [self.wkWebView setFrame:self.view.bounds];
            } else {
                [self.wkWebView setFrame:CGRectMake(self.view.frame.origin.x,
                                                    (kAMWebViewIsiPhoneX ? 88 : 64),
                                                    self.view.frame.size.width,
                                                    self.view.frame.size.height - (kAMWebViewIsiPhoneX ? 88 : 64))];
            }
            [self.wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            if (!self.wkWebView.navigationDelegate) {
                [self.wkWebView setNavigationDelegate:self];
            }
            [self.wkWebView setMultipleTouchEnabled:YES];
            [self.wkWebView setAutoresizesSubviews:YES];
            [self.wkWebView.scrollView setAlwaysBounceVertical:YES];
            [self.view addSubview:self.wkWebView];
            [self.wkWebView addObserver:self
                             forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                                options:0
                                context:HJWebContext];
            
            [self.wkWebView addObserver:self
                             forKeyPath:NSStringFromSelector(@selector(URL))
                                options:0
                                context:HJWebContext];
        }
    } else {
        if (self.uiWebView) {
            if (self.navigationController) {
                [self.uiWebView setFrame:self.view.bounds];
            } else {
                [self.uiWebView setFrame:CGRectMake(self.view.frame.origin.x,
                                                    (kAMWebViewIsiPhoneX ? 88 : 64),
                                                    self.view.frame.size.width,
                                                    self.view.frame.size.height - (kAMWebViewIsiPhoneX ? 88 : 64))];
            }
            [self.uiWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            if (!self.uiWebView.delegate) {
                [self.uiWebView setDelegate:self];
            }
            [self.uiWebView setMultipleTouchEnabled:YES];
            [self.uiWebView setAutoresizesSubviews:YES];
            [self.uiWebView.scrollView setAlwaysBounceVertical:YES];
            [self.view addSubview:self.uiWebView];
        }
    }
    
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.originalTintColor = self.navigationController.navigationBar.tintColor;
        self.originalBarTintColor = self.navigationController.navigationBar.barTintColor;
        [self setBarTintColor];
        [self updateLeftBarButtonItems];
        [self updateRightBarButtonItems];
        [self updateTitleButtonItems];
    } else {
        [self addCustomHeaderView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addProgressView];
    [self updateTitle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resetNavigationBar];
    [self removeProgressView];
}

#pragma mark - Dealloc

- (void)dealloc {
    if (self.isWK) {
        [self.wkWebView setNavigationDelegate:nil];
        if ([self isViewLoaded]) {
            [self.wkWebView removeObserver:self
                                forKeyPath:NSStringFromSelector(@selector(URL))];
            [self.wkWebView removeObserver:self
                                forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
        }
    } else {
        [self.uiWebView setDelegate:nil];
    }
}

#pragma mark - Tabar State

- (void)setShowNavigationBar:(BOOL)showNavigationBar {
    _showNavigationBar = showNavigationBar;
    
    [self updateNavigationBar];
}

- (void)setLeftButton:(UIButton *)leftButton {
    _leftButton = leftButton;
    
    [self updateLeftBarButtonItems];
}

- (void)setRightButton:(UIButton *)rightButton {
    _rightButton = rightButton;
    
    [self updateRightBarButtonItems];
}

- (void)updateNavigationBar {
    
    if (self.navigationController) {
        [self.navigationController.navigationBar setHidden:!_showNavigationBar];
    } else {
        [self.customNavigationBar setHidden:!_showNavigationBar];
    }
    
}

- (void)updateTitle {
    
    if (self.isWK) {
        if (self.wkWebView.loading) {
            if (!self.showsURLInNavigationBar) {
                return ;
            }
            
            NSString *URLString;
            if (!self.wkWebView) {
                return ;
            }
            
            URLString = [self.wkWebView.URL absoluteString];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            URLString = [URLString substringToIndex:[URLString length] - 1];
            
            if (self.navigationController) {
                [self.wkTitleButton setTitle:URLString forState:UIControlStateNormal];
                [self.wkTitleButton sizeToFit];
            } else {
                self.customNavigationBar.title = URLString;
            }
        } else {
            
            if (!self.showsPageTitleInNavigationBar) {
                return ;
            }
            
            if (!self.wkWebView) {
                return ;
            }
            
            if (self.navigationController) {
                [self.wkTitleButton setTitle:self.wkWebView.title forState:UIControlStateNormal];
                [self.wkTitleButton sizeToFit];
            } else {
                self.customNavigationBar.title = self.wkWebView.title;
            }
        }
    } else {
        if (self.uiWebView.loading) {
            if (!self.showsURLInNavigationBar) {
                return ;
            }
            
            NSString *URLString;
            if (!self.uiWebView) {
                return ;
            }
            
            URLString = [self.uiWebView.request.URL absoluteString];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            URLString = [URLString substringToIndex:[URLString length] - 1];
            
            if (self.navigationController) {
                [self.wkTitleButton setTitle:URLString forState:UIControlStateNormal];
                [self.wkTitleButton sizeToFit];
            } else {
                self.customNavigationBar.title = URLString;
            }
        } else {
            
            if (!self.showsPageTitleInNavigationBar) {
                return ;
            }
            
            if (!self.uiWebView) {
                return ;
            }
            
            NSString *theTitle = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
            if (self.navigationController) {
                [self.wkTitleButton setTitle:theTitle forState:UIControlStateNormal];
                [self.wkTitleButton sizeToFit];
            } else {
                self.customNavigationBar.title = theTitle;
            }
        }
    }
}

- (void)setBarTitleColor:(UIColor *)barTitleColor {
    if (barTitleColor) {
        if (self.navigationController) {
            [self.wkTitleButton setTitleColor:barTitleColor forState:UIControlStateNormal];
            [self.wkTitleButton sizeToFit];
        } else {
            self.customNavigationBar.titleColor = barTitleColor;
        }
    }
}

- (void)setBarTitle:(NSString *)barTitle {
    if (barTitle) {
        if (self.navigationController) {
            [self.wkTitleButton setTitle:barTitle forState:UIControlStateNormal];
            [self.wkTitleButton sizeToFit];
        } else {
            self.customNavigationBar.title = barTitle;
        }
    }
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    if (barTintColor) {
        if (self.navigationController) {
            [self.navigationController.navigationBar setBarTintColor:barTintColor];
        } else {
            [self.customNavigationBar setBackgroundColor:barTintColor];
        }
    }
}

- (void)setBarTintColor {
    if (_barTintColor) {
        if (self.navigationController) {
            [self.navigationController.navigationBar setBarTintColor:_barTintColor];
        } else {
            [self.customNavigationBar setBackgroundColor:_barTintColor];
        }
    }
}

- (void)resetNavigationBar {
    if (_originalTintColor) {
        [self.navigationController.navigationBar setTintColor:_originalTintColor];
    }
    if (_originalBarTintColor) {
        [self.navigationController.navigationBar setBarTintColor:_originalBarTintColor];
    }
}

#pragma mark - CustomHeaderView

- (void)addCustomHeaderView {
    [self.view addSubview:self.customNavigationBar];
}

- (AMWebViewNavigationBar *)customNavigationBar {
    if (!_customNavigationBar) {
        _customNavigationBar = [AMWebViewNavigationBar navigationBar];
        [_customNavigationBar.backButton addTarget:self
                                            action:@selector(backButtonPressed:)
                                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _customNavigationBar;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LeftBarButtonItems

- (NSArray <UIBarButtonItem *> *)barButtonItemWithButtons:(NSArray <UIButton *> *)buttons {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (int i = 0 ; i < buttons.count; i++) {
        UIButton *button = buttons[i];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        if (item) {
            [tempArray addObject:item];
        }
    }
    
    return tempArray;
}

- (UIButton *)titleButton {
    if (self.navigationController) {
        return self.wkTitleButton;
    } else {
        return self.customNavigationBar.titleButton;
    }
}

- (void)updateTitleButtonItems {
    
    UIColor *titleColor = [UIColor colorWithRed:68 / 255.0
                                          green:68 / 255.0
                                           blue:68 / 255.0
                                          alpha:1];
    
    _wkTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _wkTitleButton.frame = CGRectMake(0, 0, 200, 44);
    _wkTitleButton.backgroundColor = [UIColor clearColor];
    [_wkTitleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [_wkTitleButton setTitleColor:titleColor forState:UIControlStateNormal];
    
    [self.navigationController.topViewController.navigationItem setTitleView:_wkTitleButton];
}

- (void)updateRightBarButtonItems {
    
    if ( !_rightButton ) {
        return ;
    }
    
    if (self.navigationController) {
        NSArray *rightItems = [self barButtonItemWithButtons:@[_rightButton]];
        self.navigationController.topViewController.navigationItem.rightBarButtonItems = rightItems;
    } else {
        [self.customNavigationBar setRightButtons:@[_rightButton]];
    }
}

- (void)updateLeftBarButtonItems {
    
    // 如果有自定义的按钮，使用自定义的按钮
    if ( _leftButton ) {
        
        if (self.navigationController) {
            NSArray *leftItems = [self barButtonItemWithButtons:@[_leftButton]];
            self.navigationController.topViewController.navigationItem.leftBarButtonItems = leftItems;
        } else {
            [self.customNavigationBar setLeftButtons:@[_leftButton]];
        }
        return ;
    }
    
    // 没有自定义的按钮，使用默认的按钮
    if (_wkWebView && self.wkWebView.backForwardList.backList.count >= 1) {
        if ([self checkSelfIsRootViewController]) {
            self.navigationController.topViewController.navigationItem.leftBarButtonItems = @[ self.backButtonItem ];
        } else {
            self.navigationController.topViewController.navigationItem.leftBarButtonItems = @[ self.backButtonItem, self.closeButtonItem ];
        }
    } else {
        if ([self checkSelfIsRootViewController]) {
            self.navigationController.topViewController.navigationItem.leftBarButtonItems = nil;
        } else {
            self.navigationController.topViewController.navigationItem.leftBarButtonItems = @[ self.backButtonItem ];
        }
    }
}

- (UIBarButtonItem *)backButtonItem {
    UIImage *backButtonItemImage = [[UIImage imageWithContentsOfFile:[[NSBundle am_webViewBundle] pathForResource:@"nav_btn_left@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:backButtonItemImage landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    return backButtonItem;
}

- (UIBarButtonItem *)closeButtonItem {
    UIImage *closeButtonItemImage =  [[UIImage imageWithContentsOfFile:[[NSBundle am_webViewBundle] pathForResource:@"nav_btn_close@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithImage:closeButtonItemImage style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
    closeButtonItem.imageInsets = UIEdgeInsetsMake(0,0,0,20);
    return closeButtonItem;
}

#pragma mark - ProgressView

- (void)addProgressView {
    if (self.navigationController) {
        [self.navigationController.navigationBar addSubview:self.progressView];
    } else {
        [self.customNavigationBar addSubview:self.progressView];
    }
}

- (void)removeProgressView {
    if (self.progressView) {
        [self.progressView removeFromSuperview];
    }
}

- (AMWebProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[AMWebProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setTintColor:self.navigationController.navigationBar.tintColor];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        if (self.navigationController) {
            [_progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height - _progressView.frame.size.height, self.view.frame.size.width, _progressView.frame.size.height)];
        } else {
            [_progressView setFrame:CGRectMake(0, self.customNavigationBar.frame.size.height - _progressView.frame.size.height, self.view.frame.size.width, _progressView.frame.size.height)];
        }
        [_progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    }
    return _progressView;
}

#pragma mark - RefreshView

- (UIView *)refreshView {
    if (!_refreshView) {
        _refreshView = [[UIView alloc] initWithFrame:self.view.bounds];
        _refreshView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh)];
        [_refreshView addGestureRecognizer:tapgesture];
        
        UIImage *refreshImage =  [[UIImage imageWithContentsOfFile:[[NSBundle am_webViewBundle] pathForResource:@"loadfail@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:refreshImage];
        imageView.center = _refreshView.center;
        [_refreshView addSubview:imageView];
        
        UILabel *reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _refreshView.center.y + 36, _refreshView.frame.size.width, 50)];
        reminderLabel.text = @"页面加载失败，点击重新加载";
        reminderLabel.textColor = [UIColor grayColor];
        reminderLabel.font = [UIFont systemFontOfSize:15];
        reminderLabel.textAlignment = NSTextAlignmentCenter;
        [_refreshView addSubview:reminderLabel];
    }
    return _refreshView;
}

- (void)refresh {
    [self loadURL:_failUrl];
}

#pragma mark - Public Method

- (void)loadRequest:(NSURLRequest *)request {
    
    if (self.isWK) {
        if (self.wkWebView) {
            [self.wkWebView loadRequest:request];
        }
    } else {
        if (self.uiWebView) {
            [self.uiWebView loadRequest:request];
        }
    }
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    [self loadURL:[NSURL URLWithString:URLString]];
}

- (void)loadHTMLString:(NSString *)HTMLString {
    
    if (self.isWK) {
        if (self.wkWebView) {
            [self.wkWebView loadHTMLString:HTMLString baseURL:nil];
        }
    } else {
        if (self.uiWebView) {
            [self.uiWebView loadHTMLString:HTMLString baseURL:nil];
        }
    }
}

- (void)loadHTMLString:(NSString *)HTMLString baseURl:(NSURL *)baseUrl {
    if (self.isWK) {
        if (self.wkWebView) {
            [self.wkWebView loadHTMLString:HTMLString baseURL:baseUrl];
        }
    } else {
        if (self.uiWebView) {
            [self.uiWebView loadHTMLString:HTMLString baseURL:baseUrl];
        }
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView == self.uiWebView) {
        
        [self.progressView start];
        
        self.currentUrl = webView.request.URL;
        [self updateTitle];
        if ([self.delegate respondsToSelector:@selector(webView:didStartLoadingURL:)]) {
            [self.delegate webView:self didStartLoadingURL:self.uiWebView.request.URL];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if (webView == self.uiWebView) {
        [self updateTitle];
        if (self.refreshView) {
            [self.refreshView removeFromSuperview];
        }
        if (self.progressView) {
            [self.progressView setProgress:1 animated:YES];
        }
        
        if ([self.delegate respondsToSelector:@selector(webView:didFinishLoadingURL:)]) {
            [self.delegate webView:self didFinishLoadingURL:self.uiWebView.request.URL];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (webView == self.uiWebView) {
        self.failUrl = _currentUrl;
        [self updateTitle];
        if (self.refreshView && error.code != NSURLErrorCancelled) {
            [self.uiWebView addSubview:self.refreshView];
        }
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadURL:error:)]) {
            [self.delegate webView:self didFailToLoadURL:self.uiWebView.request.URL error:error];
        }
    }
}


#pragma mark - WKNavigationDelegate

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    // 解决白屏问题
    [webView reload];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    if (![navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        decisionHandler(WKNavigationResponsePolicyAllow);
        return ;
    }
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    
    // 服务器返回 200 以外的状态码时，都调用请求失败的方法。
    if (response.statusCode == 200 || response.statusCode == 304) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else {
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (webView == self.wkWebView) {
        
        if (_fakeProgress) {
            [self.progressView start];
        }
        
        self.currentUrl = webView.URL;
        [self updateTitle];
        if ([self.delegate respondsToSelector:@selector(webView:didStartLoadingURL:)]) {
            [self.delegate webView:self didStartLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (webView == self.wkWebView) {
        [self updateTitle];
        if (self.refreshView) {
            [self.refreshView removeFromSuperview];
        }
        if ([self.delegate respondsToSelector:@selector(webView:didFinishLoadingURL:)]) {
            [self.delegate webView:self didFinishLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (webView == self.wkWebView) {
        self.failUrl = _currentUrl;
        [self updateTitle];
        if (self.refreshView && error.code != NSURLErrorCancelled) {
            [self.wkWebView addSubview:self.refreshView];
        }
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadURL:error:)]) {
            [self.delegate webView:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if (webView == self.wkWebView) {
        [self updateTitle];
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadURL:error:)]) {
            [self.delegate webView:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (webView == self.wkWebView) {
        [self updateLeftBarButtonItems];
        [self updateRightBarButtonItems];
        NSURL *URL = navigationAction.request.URL;
        if (![self externalAppRequiredToOpenURL:URL]) {
            if (!navigationAction.targetFrame) {
                [self loadURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            if ([self externalAppRequiredToFileURL:URL]) {
                [self launchExternalAppWithURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - UIButton Target Action Methods

- (void)closeButtonPressed:(id)sender {
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)backButtonPressed:(id)sender {
    
    if (self.isWK) {
        if (self.wkWebView) {
            if ([self.wkWebView canGoBack]) {
                [self.wkWebView goBack];
                if (_wkWebView && self.wkWebView.backForwardList.backList.count == 1) {
                    if ([self checkSelfIsRootViewController]) {
                        self.navigationController.topViewController.navigationItem.leftBarButtonItems = @[];
                    }
                }
            } else {
                [self closeButtonPressed:self.closeButtonItem];
            }
        }
    } else {
        if (self.uiWebView) {
            if ([self.uiWebView canGoBack]) {
                [self.uiWebView goBack];
                
                if (self.uiWebView && self.uiWebView.pageCount == 1) {
                    if ([self checkSelfIsRootViewController]) {
                        self.navigationController.topViewController.navigationItem.leftBarButtonItems = @[];
                    }
                }
            } else {
                [self closeButtonPressed:self.closeButtonItem];
            }
        }
    }
    
    
    [self updateTitle];
}

#pragma mark - Estimated Progress KVO (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:kEstimatedProgress] && object == self.wkWebView) {
        [self observeProgressChange:change context:context];
    } else if ([keyPath isEqualToString:kURL]) {
        [self observeURLChange:change context:context];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)observeProgressChange:(NSDictionary *)change context:(void *)context {
    
    BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
    [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
}

- (void)observeURLChange:(NSDictionary *)change context:(void *)context {
    
    NSURL *newUrl = [change objectForKey:NSKeyValueChangeNewKey];
    
    NSURL *oldUrl = [change objectForKey:NSKeyValueChangeOldKey];
    
    if (AMWebStrIsEmpty(newUrl.absoluteString) &&
        !AMWebStrIsEmpty(oldUrl.absoluteString)) {
        
        [self.wkWebView reload];
        
    };
}

#pragma mark - Private Method

- (BOOL)checkSelfIsRootViewController {
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count > 0 &&
            [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController] == 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    NSSet *validSchemes = [NSSet setWithArray:@[ @"http", @"https" ]];
    return ![validSchemes containsObject:URL.scheme];
}

- (BOOL)externalAppRequiredToFileURL:(NSURL *)URL {
    NSSet *validSchemes = [NSSet setWithArray:@[ @"file" ]];
    return ![validSchemes containsObject:URL.scheme];
}

- (void)launchExternalAppWithURL:(NSURL *)URL {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:URL
                                           options:@{ UIApplicationOpenURLOptionUniversalLinksOnly : @NO }
                                 completionHandler:^(BOOL success){
                                 }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:URL];
#pragma clang diagnostic pop
    }
}



@end
