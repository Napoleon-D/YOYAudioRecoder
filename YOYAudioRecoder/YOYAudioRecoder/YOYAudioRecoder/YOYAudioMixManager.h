//
//  YOYAudioMixManager.h
//  YOYAudioRecoder
//
//  Created by Tommy on 2018/9/26.
//  Copyright © 2018年 Tommy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YOYAudioRecoderHeader.h"
#import "YOYCachePathManager.h"

@protocol YOYAudioMixManagerDelegate <NSObject>

/**
 录音在转m4a类型的时候，自定义设置音量大小，默认是1.0f

 @return 音量
 */
-(float)volumeForOneAudio;

/**
 合并多段音频，并增加时长
 完成合并时候的回调
 @param resultPath 最终合并完的音频，所在的沙盒路劲
 @param error 合并过程中是否出错
 */
-(void)didFinishMixAudio:(NSString *)resultPath withError:(NSError *)error;

@end

@interface YOYAudioMixManager : NSObject

@property(nonatomic,assign)id<YOYAudioMixManagerDelegate>audioMixManagerDelegate;

/**
 创建该类的一个单例

 @return 单例
 */
+(YOYAudioMixManager *)sharedAudioMixManager;

/**
 录音完成后 转 m4a格式的方法
 
 @param audioPath 源文件在沙盒的路径
 @param finishBlock 转换m4a完成时候的回调
 */
-(void)translateAudioToM4aForOneAudio:(NSString *)audioPath finish:(void(^)(NSError *error,NSString *resultPath))finishBlock;

#pragma mark 工具方法

/**
 音频截取
 若时间不足，不予截取
 返回的格式为.m4a
 
 @param anAudioPath 源录音文件
 @param time 截取的总共时间
 @param finishBlock 完成时候的回调
 */
-(void)interceptAnAudio:(NSString *)anAudioPath withTime:(float)time finish:(void(^)(NSError *error,NSString *resultPath))finishBlock;

/**
 合并多段音频
 增加音频时长
 对应的合并完成的回调方法为：didFinishMixAudio:withError:
 
 @param originalAudioArray 存放音频路径的数组
 */
-(void)mixAudio:(NSArray <NSString *>*)originalAudioArray;

/**
 根据音量，重新生成单段的音频，格式为.m4a
 
 @param originalAudioPath 录音源文件在沙盒中的路径
 @param volume 音量
 @param finishBlock 完成时候的回调
 */
-(void)regenerateOneAudio:(NSString *)originalAudioPath withVolume:(float)volume finish:(void(^)(NSError *error,NSString *resultPath))finishBlock;

/**
 音频合成，两段音频合并成一段音频，音频时长不会增加
 
 @param anAudioPath 第一段录音
 @param otherAudioPath 另一段录音
 @param finishBlock 完成时候的回调
 */
- (void)audioMixWithAudioPath:(NSString *)anAudioPath anotherAudioPath:(NSString *)otherAudioPath finish:(void(^)(NSError *error,NSString *resultPath))finishBlock;




@end

