//
//  AMBridgeWebViewController.m
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "AMBridgeWebViewController.h"

#import "AMBridgeHandleMacros.h"

#import "AMJavaScriptResponse.h"

#import "NSBundle+AMWebView.h"

#define AMBRIDGE_WEAK_SELF __weak typeof(self)weakSelf = self;
#define AMBRIDGE_STRONG_SELF __strong typeof(weakSelf)self = weakSelf;

#define ResponseCallback(_value) \
!responseCallback?:responseCallback(_value);

@interface AMBridgeWebViewController ()

@property (copy, nonatomic) NSString *leftCallBack;

@property (copy, nonatomic) NSString *rightCallBack;

@property (copy, nonatomic) NSString *titleCallBack;

@end

@implementation AMBridgeWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bridgeManager = [AMJSBridgeManager new];
    
    if (self.isWK) {
        [_bridgeManager setupBridge:self.wkWebView navigationDelegate:self];
    } else {
        [_bridgeManager setupUIBridge:self.uiWebView navigationDelegate:self];
    }
    
    [self hj_registerHander];
    
    [_bridgeManager callHandler:kWebViewDidLoad];
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_bridgeManager callHandler:kWebViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_bridgeManager callHandler:kWebViewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_bridgeManager callHandler:kWebViewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_bridgeManager callHandler:kWebViewDidDisappear];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)hj_registerHander {
    
    AMBRIDGE_WEAK_SELF
    
    /** 注册页面返回事件 */
    [_bridgeManager registerHandler:kAppExecBack handler:^(id  _Nonnull data, AMResponseCallback  _Nullable responseCallback) {
        
        AMBRIDGE_STRONG_SELF
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        ResponseCallback([AMJavaScriptResponse success]);
    }];
    
    /** 注册获取app版本事件 */
    [_bridgeManager registerHandler:kAppGetVersion handler:^(id  _Nonnull data, AMResponseCallback  _Nullable responseCallback) {
        ResponseCallback([AMJavaScriptResponse result:[AMBridgeWebViewController appVersion]]);
    }];
    
    /** 注册获取bundleID事件 */
    [_bridgeManager registerHandler:kAppGetBundleId handler:^(id  _Nonnull data, AMResponseCallback  _Nullable responseCallback) {
        ResponseCallback([AMJavaScriptResponse result:[AMBridgeWebViewController bundleIdentifier]]);
    }];
    
    /** 注册获取设备类型事件 */
    [_bridgeManager registerHandler:kAppGetDeviceType handler:^(id  _Nonnull data, AMResponseCallback  _Nullable responseCallback) {
        ResponseCallback([AMJavaScriptResponse result:@"iOS"]);
    }];
    
    /** 设置导航栏 */
    [_bridgeManager registerHandler:kAppSetNavigationBar handler:^(id  _Nonnull data, AMResponseCallback  _Nullable responseCallback) {
        
        AMBRIDGE_STRONG_SELF
        
        NSDictionary *dic = [self jsonDicFromString:data];
        
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        
        NSDictionary *nav = dic[@"nav"];
        
        if (![nav isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        
        NSDictionary *left = dic[@"nav"][@"left"];
        NSDictionary *right = dic[@"nav"][@"right"];
        NSDictionary *title = dic[@"nav"][@"title"];
        
        if (left && [left isKindOfClass:[NSDictionary class]]) {
            
            UIButton *leftButton = [self navigationButtonWithDic:left
                                                              sel:@selector(leftButtonClick:)];
            self.leftButton = leftButton;
            self.leftButton.hidden = [left[@"hide"] boolValue];
            [self.leftButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
            self.leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.leftCallBack = left[@"callback"];
            
            if (!left[@"text"] || [left[@"text"] isEqualToString:@""]) {
                UIImage *backButtonItemImage =
                [[UIImage imageWithContentsOfFile:[[NSBundle am_webViewBundle] pathForResource:@"nav_btn_left@3x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self.leftButton setImage:backButtonItemImage forState:UIControlStateNormal];
            }
        }
        
        if (right && [right isKindOfClass:[NSDictionary class]]) {
            
            UIButton *rightButton = [self navigationButtonWithDic:right
                                                              sel:@selector(rightButtonClick:)];
            self.rightButton = rightButton;
            self.rightButton.hidden = [right[@"hide"] boolValue];
            [self.rightButton.titleLabel setTextAlignment:NSTextAlignmentRight];
            self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            self.rightCallBack = right[@"callback"];
        }
        
        if (title && [title isKindOfClass:[NSDictionary class]]) {
            
            UIColor *color = [self hjweb_colorWithHexString:title[@"textColor"]];
            
            self.barTitle = title[@"text"];
            self.barTitleColor = color;
            self.titleCallBack = title[@"callback"];
            
            UITapGestureRecognizer *doubelTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleButtonClick:)];
            
            doubelTap.numberOfTapsRequired = 2;
            
            [self.titleButton addGestureRecognizer:doubelTap];
        }
        
        UIColor *bgColor = [self hjweb_colorWithHexString:nav[@"bgColor"]];
        self.barTintColor = bgColor;
        self.showNavigationBar = ![nav[@"hide"] boolValue];
    }];
    
}

- (UIButton *)navigationButtonWithDic:(NSDictionary *)dic sel:(SEL)sel {
    
    UIColor *color = [self hjweb_colorWithHexString:dic[@"textColor"]] ?: [self hjweb_colorWithHexString:@"#333333"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 44);
    [button setTitle:dic[@"text"] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button addTarget:self
               action:sel
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)titleButtonClick:(UIButton *)sender {
    
    if (self.isWK) {
        [self.wkWebView evaluateJavaScript:_titleCallBack
                         completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                             
                         }];
    } else {
        [self.uiWebView stringByEvaluatingJavaScriptFromString:_titleCallBack];
    }
}

- (void)leftButtonClick:(UIButton *)sender {
    
    if (self.isWK) {
        if (!self.leftCallBack) {
            if ([self.wkWebView canGoBack]) {
                [self.wkWebView goBack];
            } else {
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            return ;
        }
        
        [self.wkWebView evaluateJavaScript:_leftCallBack
                         completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                             
                         }];
    } else {
        if (!self.leftCallBack) {
            if ([self.uiWebView canGoBack]) {
                [self.uiWebView goBack];
            } else {
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            return ;
        }
        
        [self.uiWebView stringByEvaluatingJavaScriptFromString:_leftCallBack];
    }
}

- (void)rightButtonClick:(UIButton *)sender {
    
    if (self.isWK) {
        [self.wkWebView evaluateJavaScript:_rightCallBack
                         completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                             
                         }];
    } else {
        [self.uiWebView stringByEvaluatingJavaScriptFromString:_rightCallBack];
    }
}

CGFloat hjweb_colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

- (UIColor *)hjweb_colorWithHexString:(NSString *)hexString {
    CGFloat alpha, red, blue, green;
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = hjweb_colorComponentFrom(colorString, 0, 1);
            green = hjweb_colorComponentFrom(colorString, 1, 1);
            blue  = hjweb_colorComponentFrom(colorString, 2, 1);
            break;
            
        case 4: // #ARGB
            alpha = hjweb_colorComponentFrom(colorString, 0, 1);
            red   = hjweb_colorComponentFrom(colorString, 1, 1);
            green = hjweb_colorComponentFrom(colorString, 2, 1);
            blue  = hjweb_colorComponentFrom(colorString, 3, 1);
            break;
            
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = hjweb_colorComponentFrom(colorString, 0, 2);
            green = hjweb_colorComponentFrom(colorString, 2, 2);
            blue  = hjweb_colorComponentFrom(colorString, 4, 2);
            break;
            
        case 8: // #AARRGGBB
            alpha = hjweb_colorComponentFrom(colorString, 0, 2);
            red   = hjweb_colorComponentFrom(colorString, 2, 2);
            green = hjweb_colorComponentFrom(colorString, 4, 2);
            blue  = hjweb_colorComponentFrom(colorString, 6, 2);
            break;
            
        default:
            return nil;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSDictionary *)jsonDicFromString:(NSString *)string {
    
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
    return dic;
}

+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)bundleIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}
    
- (void)dealloc {
    NSLog(@"dealloc ++++");
}


@end
