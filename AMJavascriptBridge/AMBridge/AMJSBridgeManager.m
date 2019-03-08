//
//  AMJSBridgeManager.m
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "AMJSBridgeManager.h"
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

@interface AMJSBridgeManager ()

@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@property (nonatomic, strong) WebViewJavascriptBridge *uibridge;
@property (nonatomic, copy) NSArray<id<AMBridgeProtocol>> * handers;
@property (nonatomic, strong)NSMutableDictionary *dictHanders;

@end

@implementation AMJSBridgeManager

#pragma mark -

+ (void)enableLogging {
    [WKWebViewJavascriptBridge enableLogging];
}

#pragma mark - setup

- (void)setupBridge:(WKWebView *)webView {
    [self setupBridge:webView navigationDelegate:nil];
}

- (void)setupUIBridge:(UIWebView *)webView {
    [self setupUIBridge:webView navigationDelegate:nil];
}

- (void)setupUIBridge:(UIWebView *)webView navigationDelegate:(id)delegate {
    _uibridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    if (delegate) {
        [_uibridge setWebViewDelegate:delegate];
    }
}

- (void)setupBridge:(WKWebView *)webView navigationDelegate:(id)delegate {
    
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    if (delegate) {
        [_bridge setWebViewDelegate:delegate];
    }
}

#pragma mark - register

- (void)registerHandler:(NSString*)handlerName voidHandler:(AMVoidHandler)handler {
    
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (handler) { handler();}
        }];
    } else {
        [_uibridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (handler) { handler();}
        }];
    }
}

- (void)registerHandler:(NSString*)handlerName dictHandler:(AMDictHandler)handler {
    
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                handler((NSDictionary *)data);
            }
        }];
    } else {
        [_uibridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                handler((NSDictionary *)data);
            }
        }];
    }
    
    
}

- (void)registerHandler:(NSString*)handlerName dictRespHandler:(AMDictRespHandler)handler {
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                handler((NSDictionary *)data, responseCallback);
            }
        }];
    } else {
        [_uibridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                handler((NSDictionary *)data, responseCallback);
            }
        }];
    }
}

- (void)registerHandler:(NSString *)handlerName handler:(AMHandler)handler {
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:handler];
    } else {
        [_uibridge registerHandler:handlerName handler:handler];
    }
}

- (void)registerHandler:(id<AMBridgeProtocol>)handler {
    
    NSString *handlerName = [handler handlerName];
    
    if (_bridge) {
        [_bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if ([handler respondsToSelector:@selector(didReceiveMessage:hander:)]) {
                [handler didReceiveMessage:data hander:responseCallback];
            }
            if ([handler respondsToSelector:@selector(didReceiveMessage:)]) {
                [handler didReceiveMessage:data];
            }
        }];
    } else {
        [_uibridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if ([handler respondsToSelector:@selector(didReceiveMessage:hander:)]) {
                [handler didReceiveMessage:data hander:responseCallback];
            }
            if ([handler respondsToSelector:@selector(didReceiveMessage:)]) {
                [handler didReceiveMessage:data];
            }
        }];
    }
}

#pragma mark - call

- (void)callHandler:(NSString*)handlerName {
    [self callHandler:handlerName data:nil];
}

- (void)callHandler:(NSString*)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(AMResponseCallback)responseCallback {
    if (_bridge) {
        [_bridge callHandler:handlerName data:data responseCallback:responseCallback];
    } else {
        [_uibridge callHandler:handlerName data:data responseCallback:responseCallback];
    }
    
}

- (void)callHandler:(NSString*)handlerName data:(id)data dictResponseCallback:(AMDictResponseCallback)responseCallback {
    
    if (_bridge) {
        [_bridge callHandler:handlerName data:data responseCallback:^(id responseData) {
            if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
                responseCallback((NSDictionary *)responseData);
            }
        }];
    } else {
        [_uibridge callHandler:handlerName data:data responseCallback:^(id responseData) {
            if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
                responseCallback((NSDictionary *)responseData);
            }
        }];
    }
    
    
}

#pragma mark - multiple

/**
 初始化遵循AMBridgeProtocol协议的hander组
 */
- (void)addHandlers:(NSArray<id<AMBridgeProtocol>> *)handers {
    for (id<AMBridgeProtocol> hander in handers) {
        [self addHander:hander];
    }
}

- (void)addHander:(id<AMBridgeProtocol>)hander {
    NSString *handerName = nil;
    if ([hander respondsToSelector:@selector(handlerName)]) {
        handerName = [hander handlerName];
    }
    if (!handerName || [_dictHanders objectForKey:handerName]) { return; }
    [_dictHanders setValue:hander forKey:handerName];
    [self registerHandler:handerName handler:^(id  _Nonnull data, AMResponseCallback  _Nullable responseCallback) {
        if ([hander respondsToSelector:@selector(didReceiveMessage:hander:)]) {
            [hander didReceiveMessage:data hander:responseCallback];
        }
        if ([hander respondsToSelector:@selector(didReceiveMessage:)] && [data isKindOfClass:[NSDictionary class]]) {
            [hander didReceiveMessage:(NSDictionary *)data];
        }
    }];
}

@end
