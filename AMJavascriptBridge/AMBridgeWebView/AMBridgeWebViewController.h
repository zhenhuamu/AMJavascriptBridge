//
//  AMBridgeWebViewController.h
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "AMWebViewController.h"

#import "AMJSBridgeManager.h"

@interface AMBridgeWebViewController : AMWebViewController

/**
 桥接管理器
 */
@property (strong, nonatomic) AMJSBridgeManager *bridgeManager;

@end
