//
//  AMBridgeHandleMacros.h
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#ifndef AMBridgeHandleMacros_h
#define AMBridgeHandleMacros_h

/*!
 app页面返回
 */
static NSString * const kAppExecBack = @"appExecBack";

/*!
 获取app版本
 */
static NSString * const kAppGetVersion = @"appGetVersion";

/*!
 获取bundleID
 */
static NSString * const kAppGetBundleId = @"appGetBundleId";

/*!
 获取设备类型 (iOS/Android)
 */
static NSString * const kAppGetDeviceType = @"appGetDeviceType";

/*!
 获取设备唯一标识
 */
static NSString * const kAppGetDeviceUID = @"appGetDeviceUID";

/*!
 打开webView
 */
static NSString * const kAppOpenWebview = @"appOpenWebview";

/*!
 页面加载
 */
static NSString * const kWebViewDidLoad = @"webViewDidLoad";

/*!
 页面将要显示
 */
static NSString * const kWebViewWillAppear = @"webViewWillAppear";

/*!
 页面已经显示
 */
static NSString * const kWebViewDidAppear = @"webViewDidAppear";

/*!
 页面将要消失
 */
static NSString * const kWebViewWillDisappear = @"webViewWillDisappear";

/*!
 页面已经消失
 */
static NSString * const kWebViewDidDisappear = @"webViewDidDisappear";

/*!
 设置导航栏
 */
static NSString * const kAppSetNavigationBar = @"appSetNavigationBar";

#endif /* AMBridgeHandleMacros_h */
