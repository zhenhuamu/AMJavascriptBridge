//
//  AMJavaScriptResponse.m
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import "AMJavaScriptResponse.h"

static NSString * const jsSuccessCode = @"success";

@implementation AMJavaScriptResponse

+ (NSString *)responseCode:(NSString *)code error:(NSString *)error result:(id)result {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:code forKey:@"code"];
    [dic setValue:error forKey:@"error"];
    [dic setValue:result forKey:@"result"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)success {
    return [self responseCode:jsSuccessCode error:nil result:nil];
}

+ (NSString *)result:(id)result {
    return [self responseCode:jsSuccessCode error:nil result:result];
}

@end
