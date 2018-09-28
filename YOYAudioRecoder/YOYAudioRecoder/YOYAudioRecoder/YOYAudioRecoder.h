//
//  YOYAudioRecoder.h
//  YOYAudioRecoder
//
//  Created by Tommy on 2018/9/26.
//  Copyright © 2018年 Tommy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YOYAudioRecoderHeader.h"
#import "YOYCachePathManager.h"
#import "YOYAudioMixManager.h"
#import "NSTimer+WTCExtend.h"

@protocol YOYAudioRecoderDelegate <NSObject>

@optional

/**
 音频的录制时间-->1s执行一次
 
 @param time 当前录制的总时间
 */
-(void)recodingForTime:(NSTimeInterval)time;

/**
 完成录制的回调

 @param error 错误
 @param audioPath 录音的文件沙盒路径
 @param totalTime 录音的总时间
 */
-(void)didFinishedAudioRecoderWithError:(NSError *)error audioPath:(NSString *)audioPath totalTime:(NSTimeInterval)totalTime;

/**
 设置自定义的采样率，默认是44100

 @return 采样率
 */
-(NSInteger)valueForAVSampleRateKey;

/**
 设置自定义的bit，默认是32

 @return bit
 */
-(NSInteger)valueForAVLinearPCMBitDepthKey;

-(NSString *)categoryForAVAudioSessionWhenStartRecoder;

/// AVAudioSessionCategoryOptionAllowBluetooth
-(NSInteger)optionForAVAudioSessionWhenStartRecoder;

-(NSString *)categoryForAVAudioSessionWhenFinishedRecoder;

/// AVAudioSessionCategoryOptionAllowBluetooth
-(NSInteger)optionForAVAudioSessionWhenFinishedRecoder;

@end

@interface YOYAudioRecoder : NSObject

@property(nonatomic,assign)id<YOYAudioRecoderDelegate>audioRecoderDelegate;

/**
 创建该类的一个单例

 @return 单例
 */
+(YOYAudioRecoder *)sharedAudioRecoder;

/**
 开始录音
 */
-(void)startAudioRecoder;

/**
 暂停录音
 */
-(void)pauseAudioRecoder;

/**
 继续录音
 */
-(void)resumeAudioRecoder;

/**
 停止录音
 */
-(void)stopAudioRecoder;

@end

