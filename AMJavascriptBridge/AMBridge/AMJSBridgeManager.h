//
//  AMJSBridgeManager.h
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^AMResponseCallback)(id _Nullable responseData);
typedef void (^AMDictResponseCallback)(NSDictionary * _Nullable responseData);

typedef void (^AMVoidHandler)(void);
typedef void (^AMDictHandler)(NSDictionary * _Nonnull data);
typedef void (^AMDictRespHandler)(NSDictionary * _Nonnull data, AMResponseCallback _Nullable responseCallback);
typedef void (^AMHandler)(id _Nonnull data, AMResponseCallback _Nullable responseCallback);

NS_ASSUME_NONNULL_BEGIN

@protocol AMBridgeProtocol <NSObject>

@required

/**
 js调用native的方法名
 */
- (NSString *)handlerName;

@optional

/**
 native接收到的JS传过来的数据
 */
- (void)didReceiveMessage:(id)message;

- (void)didReceiveMessage:(id)message hander:(AMResponseCallback)hander;

@end



@interface AMJSBridgeManager : NSObject

/**
 是否输出日志
 */
+ (void)enableLogging;

/**
 初始化Bridge
 
 @param webView webView
 param navigationDelegate 需要自定义实现navigationDelegate的方法
 */
- (void)setupBridge:(WKWebView *)webView;

- (void)setupBridge:(WKWebView *)webView navigationDelegate:(id _Nullable)delegate;

/**
 初始化Bridge
 
 @param webView webView
 param navigationDelegate 需要自定义实现navigationDelegate的方法
 */
- (void)setupUIBridge:(UIWebView *)webView;

- (void)setupUIBridge:(UIWebView *)webView navigationDelegate:(id _Nullable)delegate;

#pragma mark - single

/**
 注册方法，供JS端调用
 
 @param handlerName 方法名
 @param handler 回调
 */
- (void)registerHandler:(NSString*)handlerName voidHandler:(AMVoidHandler)handler;

- (void)registerHandler:(NSString*)handlerName dictHandler:(AMDictHandler)handler;

- (void)registerHandler:(NSString*)handlerName dictRespHandler:(AMDictRespHandler)handler;

- (void)registerHandler:(NSString*)handlerName handler:(AMHandler)handler;

- (void)registerHandler:(id<AMBridgeProtocol>)handler;

/**
 调用在JS端已经预埋好的方法
 
 @param handlerName 方法名
 param data 传递的数据
 param responseCallback JS接受后的回调
 */
- (void)callHandler:(NSString*)handlerName;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data responseCallback:(AMResponseCallback _Nullable)responseCallback;

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data dictResponseCallback:(AMDictResponseCallback _Nullable)responseCallback;

#pragma mark - multiple

/**
 初始化遵循AMBridgeProtocol协议的hander组
 */
- (void)addHandlers:(NSArray<id<AMBridgeProtocol>> *)handers;

/**
 handers的映射关系组
 */
@property (nonatomic, strong, readonly)NSMutableDictionary *dictHanders;

@end

NS_ASSUME_NONNULL_END

