//
//  NSTimer+NSTimerExtend.h
//  BiBiClick
//
//  Created by Tommy on 2018/7/24.
//  Copyright © 2018年 hbtime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (WTCExtend)

/// 建议使用懒加载的方式加载NSTimer对象
+ (NSTimer *)initTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

- (void)startTimer;

- (void)pauseTimer;

- (void)resumeTimer;

/**
 调用完该方法，记得将NSTime对象置成nil
 */
- (void)stopTimer;

@end
