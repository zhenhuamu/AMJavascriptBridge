//
//  AMPrivacyPolicy.m
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "AMPrivacyPolicy.h"

#import "AMWebViewController.h"
#import <SafariServices/SFSafariViewController.h>

@interface AMPrivacyPolicy ()<SFSafariViewControllerDelegate>

@end

@implementation AMPrivacyPolicy

static AMPrivacyPolicy *privacyPolicyManager;

- (void)loadURL:(NSURL *)url fromViewController:(UIViewController *)viewController {
    
    if (@available(iOS 9.0, *)) {
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
        [viewController presentViewController:safariViewController animated:YES completion:nil];
    } else {
        AMWebViewController *wkWebViewController = [AMWebViewController webView];
        [wkWebViewController loadURL:url];
        if (viewController.navigationController) {
            [viewController.navigationController pushViewController:wkWebViewController animated:YES];
        } else {
            wkWebViewController.showNavigationBar = YES;
            [viewController presentViewController:wkWebViewController animated:YES completion:nil];
        }
    }
}

- (void)loadFile:(NSURL *)file fromViewController:(UIViewController *)viewController {
    
    AMWebViewController *uiWebViewController = [AMWebViewController webView];
    uiWebViewController.isWK = NO;
    [uiWebViewController loadURL:file];
    if (viewController.navigationController) {
        [viewController.navigationController pushViewController:uiWebViewController animated:YES];
    } else {
        uiWebViewController.showNavigationBar = YES;
        [viewController presentViewController:uiWebViewController animated:YES completion:nil];
    }
}

@end
