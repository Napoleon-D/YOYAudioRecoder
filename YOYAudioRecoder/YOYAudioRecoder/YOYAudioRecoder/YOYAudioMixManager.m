//
//  YOYAudioMixManager.m
//  YOYAudioRecoder
//
//  Created by Tommy on 2018/9/26.
//  Copyright © 2018年 Tommy. All rights reserved.
//

#import "YOYAudioMixManager.h"

@interface YOYAudioMixManager()

@property(nonatomic,strong)YOYCachePathManager *pathManager;

@end

@implementation YOYAudioMixManager

/**
 创建该类的一个单例
 
 @return 单例
 */
+(YOYAudioMixManager *)sharedAudioMixManager{

    static YOYAudioMixManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
    
}

/**
 录音完成后 转 m4a格式的方法

 @param audioPath 源文件在沙盒的路径
 @param finishBlock 转换m4a完成时候的回调
 */
-(void)translateAudioToM4aForOneAudio:(NSString *)audioPath finish:(void(^)(NSError *error,NSString *resultPath))finishBlock{
    float volume = 1.0f;
    if ([self.audioMixManagerDelegate respondsToSelector:@selector(volumeForOneAudio)]) {
        volume = [self.audioMixManagerDelegate volumeForOneAudio];
    }
    [self regenerateOneAudio:audioPath withVolume:volume finish:^(NSError *error, NSString *resultPath) {
        if (finishBlock) {
            finishBlock(error,resultPath);
        }
    }];
}

#pragma mark 工具方法

/**
 合并多段音频
 增加音频时长
 对应的合并完成的回调方法为：didFinishMixAudio:withError:

 @param originalAudioArray 存放音频路径的数组
 */
-(void)mixAudio:(NSArray <NSString *>*)originalAudioArray{
    
    if ((originalAudioArray.count <= 0) || (!originalAudioArray)) {
        if ([self.audioMixManagerDelegate respondsToSelector:@selector(didFinishMixAudio:withError:)]) {
            NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:-1 userInfo:nil];
            [self.audioMixManagerDelegate didFinishMixAudio:nil withError:error];
        }
    }else if (originalAudioArray.count == 1) {
        if ([self.audioMixManagerDelegate respondsToSelector:@selector(didFinishMixAudio:withError:)]) {
            NSString *resultPath = [originalAudioArray firstObject];
            [self.audioMixManagerDelegate didFinishMixAudio:resultPath withError:nil];
        }
    }else{
        NSString *firstPath = originalAudioArray[0];
        NSString *secondPath = originalAudioArray[1];
        [self firstPath:firstPath secondPath:secondPath finish:^(NSError *error, NSString *resultPath) {
            if (error) {
                if ([self.audioMixManagerDelegate respondsToSelector:@selector(didFinishMixAudio:withError:)]) {
                    NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:-1 userInfo:nil];
                    [self.audioMixManagerDelegate didFinishMixAudio:nil withError:error];
                }
            }else{
                NSMutableArray *audioMutableArray = [NSMutableArray arrayWithArray:originalAudioArray];
                [audioMutableArray removeObjectAtIndex:0];
                [audioMutableArray removeObjectAtIndex:0];
                [audioMutableArray insertObject:resultPath atIndex:0];
                [self mixAudio:audioMutableArray];
            }
        }];
    }
}

/**
 两段音频合并成一段音频
 增加音频时长

 @param path 第一段录音
 @param secondPath 第二段录音
 @param finishBlock 完成时候的回调
 */
- (void)firstPath:(NSString *)path secondPath:(NSString *)secondPath finish:(void(^)(NSError *error,NSString *resultPath))finishBlock{
    
    AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    AVURLAsset *audioAsset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:secondPath]];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 音频通道
    AVMutableCompositionTrack *audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVMutableCompositionTrack *audioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    
    // 音频采集通道
    AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *audioAssetTrack2 = [[audioAsset2 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset1.duration) ofTrack:audioAssetTrack1 atTime:kCMTimeZero error:nil];
    [audioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset2.duration) ofTrack:audioAssetTrack2 atTime:audioAsset1.duration error:nil];
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    NSString *targetPath = [self.pathManager savedPathForM4aAudio];
    session.outputURL = [NSURL fileURLWithPath:targetPath];
    session.outputFileType = AVFileTypeAppleM4A;
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        if ([defaultManager fileExistsAtPath:targetPath]) {
            if (finishBlock) {
                finishBlock(nil,targetPath);
            }
        }else{
            NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:-1 userInfo:nil];
            if (finishBlock) {
                finishBlock(error,nil);
            }
        }
    }];
}

/**
 音频截取
 若时间不足，不予截取
 返回的格式为.m4a

 @param anAudioPath 源录音文件
 @param time 截取的总共时间
 @param finishBlock 完成时候的回调
 */
-(void)interceptAnAudio:(NSString *)anAudioPath withTime:(float)time finish:(void(^)(NSError *error,NSString *resultPath))finishBlock{
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:anAudioPath] options:nil];
    float totalTime = CMTimeGetSeconds(audioAsset.duration);
    
    if (totalTime <= time) {
        /// 时间不足，不予截取
        if (finishBlock) {
            finishBlock(nil,anAudioPath);
        }
    }else{
        /// 时间充足，进行截取
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];
        NSString *targetPath = [self.pathManager savedPathForM4aAudio];
        exportSession.outputURL = [NSURL fileURLWithPath:targetPath];
        exportSession.outputFileType = AVFileTypeAppleM4A;
        exportSession.shouldOptimizeForNetworkUse = YES;
        CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(CMTimeMake(0, 1), CMTimeMake(time, 1));
        exportSession.timeRange = exportTimeRange;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{

            NSFileManager *file = [NSFileManager defaultManager];
            if ([file fileExistsAtPath:targetPath]) {
                if (finishBlock) {
                    finishBlock(nil,targetPath);
                }
            }else{
                NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:-1 userInfo:nil];
                if (finishBlock) {
                    finishBlock(error,nil);
                }
            }
        }];
        
    }
    
}

/**
 音频合成，两段音频合并成一段音频，音频时长不会增加

 @param anAudioPath 第一段录音
 @param otherAudioPath 另一段录音
 @param finishBlock 完成时候的回调
 */
- (void)audioMixWithAudioPath:(NSString *)anAudioPath anotherAudioPath:(NSString *)otherAudioPath finish:(void(^)(NSError *error,NSString *resultPath))finishBlock{
    
    AVMutableComposition *composion = [AVMutableComposition composition];
    AVMutableCompositionTrack *anAudio = [composion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *otherAudio = [composion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    ///  添加第一段声音轨
    AVURLAsset *anAudioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:anAudioPath] options:nil];
    AVAssetTrack *anAudioTrack = [[anAudioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [anAudio insertTimeRange:CMTimeRangeMake(kCMTimeZero, anAudioAsset.duration) ofTrack:anAudioTrack atTime:kCMTimeZero error:nil];
    
    ///  添加另一段音轨
    AVURLAsset *otherAudioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:otherAudioPath] options:nil];
    AVAssetTrack *otherAudioTrack = [[otherAudioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [otherAudio insertTimeRange:CMTimeRangeMake(kCMTimeZero, otherAudioAsset.duration) ofTrack:otherAudioTrack atTime:kCMTimeZero error:nil];
    
    ///  生成输出文件-->.m4a格式
    NSString *targetPath = [self.pathManager savedPathForM4aAudio];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composion presetName:AVAssetExportPresetAppleM4A];
    exportSession.outputURL = [NSURL fileURLWithPath:targetPath];
    exportSession.outputFileType = @"com.apple.m4a-audio";
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
            ///  音频文件合成成功
            if (finishBlock) {
                finishBlock(nil,targetPath);
            }
        }else{
            ///  音频文件合成失败
            NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:-1 userInfo:nil];
            if (finishBlock) {
                finishBlock(error,nil);
            }
        }
    }];
    
}

/**
 根据音量，重新生成单段的音频，格式为.m4a

 @param originalAudioPath 录音源文件在沙盒中的路径
 @param volume 音量
 @param finishBlock 完成时候的回调
 */
-(void)regenerateOneAudio:(NSString *)originalAudioPath withVolume:(float)volume finish:(void(^)(NSError *error,NSString *resultPath))finishBlock{
    
    NSString *resultPath = [self.pathManager savedPathForM4aAudio];
    
    AVURLAsset *originalAudioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:originalAudioPath] options:nil];
    AVAssetTrack *originalAudioTrack = [[originalAudioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVMutableAudioMixInputParameters *originalAudioParameter = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:originalAudioTrack];
    [originalAudioParameter setVolume:volume atTime:kCMTimeZero];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[originalAudioParameter];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:originalAudioAsset presetName:AVAssetExportPresetAppleM4A];
    exportSession.audioMix = audioMix;
    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
    exportSession.outputFileType = @"com.apple.m4a-audio";
    exportSession.shouldOptimizeForNetworkUse = YES;

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        
        if ([defaultManager fileExistsAtPath:resultPath]) {
            [defaultManager removeItemAtPath:originalAudioPath error:nil];
            if (finishBlock) {
                finishBlock(nil,resultPath);
            }
        }else{
            NSLog(@"录音转m4a格式失败");
            if (finishBlock) {
                NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:999 userInfo:nil];
                finishBlock(error,nil);
            }
        }
        
    }];
}



#pragma mark 私有方法

- (YOYCachePathManager *)pathManager{
    if (!_pathManager) {
        _pathManager = [YOYCachePathManager sharedCachePathManager];
    }
    return _pathManager;
}


@end
