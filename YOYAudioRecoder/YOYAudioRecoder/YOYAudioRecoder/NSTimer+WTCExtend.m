
//
//  NSTimer+NSTimerExtend.m
//  BiBiClick
//
//  Created by Tommy on 2018/7/24.
//  Copyright © 2018年 hbtime. All rights reserved.
//

#import "NSTimer+WTCExtend.h"

@implementation NSTimer (WTCExtend)

/// 建议使用懒加载的方式加载NSTimer对象
+ (NSTimer *)initTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    return timer;
}

- (void)startTimer{
    [self fire];
}

- (void)pauseTimer{
    [self setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer{
    [self setFireDate:[NSDate distantPast]];
}

/**
 调用完该方法，记得将NSTime对象置成nil
 */
- (void)stopTimer{
    [self invalidate];
}

@end
