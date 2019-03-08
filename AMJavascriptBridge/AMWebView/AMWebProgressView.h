//
//  AMWebProgressView.h
//  AMJavascriptBridge
//
//  Created by AndyMu on 2017/12/28.
//  Copyright © 2017年 AndyMu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMWebProgressView : UIProgressView

/**
 到达伪目标的时间
 */
@property (assign, nonatomic) NSTimeInterval fakeDuration;

/**
 到达伪目标的次数
 */
@property (assign, nonatomic) NSInteger fakeCount;

/**
 伪目标百分比
 */
@property (assign, nonatomic) CGFloat fakeProgress;

/**
 开始加载数据
 */
- (void)start;

@end
