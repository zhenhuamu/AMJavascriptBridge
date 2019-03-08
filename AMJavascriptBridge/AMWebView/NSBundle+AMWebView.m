//
//  NSBundle+AMWebView.m
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "NSBundle+AMWebView.h"
#import "AMWebViewController.h"

@implementation NSBundle (AMWebView)

+ (instancetype)am_webViewBundle {
    static NSBundle *webViewBundle = nil;
    if (webViewBundle == nil) {
        webViewBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[AMWebViewController class]] pathForResource:@"AMWebView" ofType:@"bundle"]];
    }
    return webViewBundle;
}

@end
