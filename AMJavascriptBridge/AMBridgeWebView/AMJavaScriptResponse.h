//
//  AMJavaScriptResponse.h
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMJavaScriptResponse : NSObject

+ (NSString *)success;

+ (NSString *)result:(id)result;

+ (NSString *)responseCode:(NSString *)code error:(NSString *)error result:(id)result;

@end
