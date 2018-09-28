//
//  YOYAudioRecoder.m
//  YOYAudioRecoder
//
//  Created by Tommy on 2018/9/26.
//  Copyright © 2018年 Tommy. All rights reserved.
//

#import "YOYAudioRecoder.h"

@interface YOYAudioRecoder()<AVAudioRecorderDelegate>

///  音频会话
@property(nonatomic,strong)AVAudioSession *audioSession;
///  录音器
@property(nonatomic,strong)AVAudioRecorder *audioRecoder;
/// 文件路径管理
@property(nonatomic,strong)YOYCachePathManager *pathManager;
/// 录音合成管理
@property(nonatomic,strong)YOYAudioMixManager *audioMixManager;
/// 一段录音的沙盒路径
@property(nonatomic,copy)NSString *audioFilePath;
/// 定时器
@property(nonatomic,strong)NSTimer *timer;
/// 总时间
@property(nonatomic,assign)NSTimeInterval totalTime;

@end

@implementation YOYAudioRecoder

/**
 创建该类的一个单例
 
 @return 单例
 */
+(YOYAudioRecoder *)sharedAudioRecoder{
    static YOYAudioRecoder *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype)init{
    if (self = [super init]) {
        /// 创建沙盒目录
        [self.pathManager createCacheFileDir];
        /// 移除多余录音文件
        [self.pathManager removeAudioFiles];
        _audioFilePath = @"";
    }
    return self;
}

/**
 开始录音
 */
-(void)startAudioRecoder{
    
    self.totalTime = -1;
    [self setCategoryForAudioSessionForStatus:1];
    [self.audioRecoder prepareToRecord];
    [_audioRecoder record];
    [self.timer startTimer];

}

/**
 暂停录音
 */
-(void)pauseAudioRecoder{
    [_audioRecoder pause];
    [self.timer pauseTimer];
}

/**
 继续录音
 */
-(void)resumeAudioRecoder{
    [_audioRecoder prepareToRecord];
    [_audioRecoder record];
    [self.timer resumeTimer];
}

/**
 停止录音
 */
-(void)stopAudioRecoder{
    [_audioRecoder stop];
    [self.timer stopTimer];
    self.timer = nil;
}

#pragma mark AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    NSLog(@"=========录音完成============");
    [self setCategoryForAudioSessionForStatus:0];
    
    /// 音频文件总时长
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.audioFilePath] options:nil];
    self.totalTime = CMTimeGetSeconds(audioAsset.duration);
    
    if ([self.audioRecoderDelegate respondsToSelector:@selector(recodingForTime:)]) {
        [self.audioRecoderDelegate recodingForTime:self.totalTime];
    }
    
    [self.audioMixManager translateAudioToM4aForOneAudio:self.audioFilePath finish:^(NSError *error, NSString *resultPath) {

//        NSLog(@"%@",resultPath);
        if (error) {
            self.audioFilePath = nil;
        }else{
            self.audioFilePath = resultPath;
        }
        if ([self.audioRecoderDelegate respondsToSelector:@selector(didFinishedAudioRecoderWithError:audioPath:totalTime:)]) {
            [self.audioRecoderDelegate didFinishedAudioRecoderWithError:error audioPath:self.audioFilePath totalTime:self.totalTime];
        }
        
    }];
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
//    NSLog(@"=======录音出错==========");
    [self setCategoryForAudioSessionForStatus:0];
    self.audioFilePath = nil;
    if ([self.audioRecoderDelegate respondsToSelector:@selector(didFinishedAudioRecoderWithError:audioPath:totalTime:)]) {
        [self.audioRecoderDelegate didFinishedAudioRecoderWithError:error audioPath:self.audioFilePath totalTime:self.totalTime];
    }
}

#pragma mark 私有方法

/**
 定时器方法
 */
-(void)timerMethod{
    self.totalTime++;
    if ([self.audioRecoderDelegate respondsToSelector:@selector(recodingForTime:)]) {
        [self.audioRecoderDelegate recodingForTime:self.totalTime];
    }
}

/**
 设置录音会话的属性

 @param status 录音状态-->0:结束录音;1-->开始录音
 */
-(void)setCategoryForAudioSessionForStatus:(NSInteger)status{
    [self.audioSession setActive:YES error:nil];
    NSString *category = AVAudioSessionCategoryPlayAndRecord;
    NSInteger option = AVAudioSessionCategoryOptionAllowBluetooth;
    switch (status) {
        case 0:{
            /// 结束录音
            
            if ([self.audioRecoderDelegate respondsToSelector:@selector(categoryForAVAudioSessionWhenFinishedRecoder)]) {
                NSString *tmp = [self.audioRecoderDelegate categoryForAVAudioSessionWhenFinishedRecoder];
                if (tmp) category = tmp;
            }
            if ([self.audioRecoderDelegate respondsToSelector:@selector(optionForAVAudioSessionWhenFinishedRecoder)]) {
                option = [self.audioRecoderDelegate optionForAVAudioSessionWhenFinishedRecoder];
            }
            
            break;
        }
        case 1:{
            /// 开始录音
            
            if ([self.audioRecoderDelegate respondsToSelector:@selector(categoryForAVAudioSessionWhenStartRecoder)]) {
                NSString *tmp = [self.audioRecoderDelegate categoryForAVAudioSessionWhenStartRecoder];
                if (tmp) category = tmp;
            }
            if ([self.audioRecoderDelegate respondsToSelector:@selector(optionForAVAudioSessionWhenStartRecoder)]) {
                option = [self.audioRecoderDelegate optionForAVAudioSessionWhenStartRecoder];
            }
            
            break;
        }
        default:
            break;
    }
    NSError *error;
    [self.audioSession setCategory:category withOptions:option error:&error];
    if (error) {
        NSLog(@"setCategoryForAudioSessionForStatusError11:%@",error);
    }
    NSError *sessionError;
    if (![self isHeadsetPluggedIn]) {
        /// 未插入耳机
        [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&sessionError];
        if (sessionError) {
            NSLog(@"sessionError:%@",error);
        }
    }
}

/**
 检测是否插入耳机-->包括蓝牙耳机
 
 @return YES:插入/NO:未插入
 */
-(BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        NSString *portType = [desc portType];
        if ([portType isEqualToString:AVAudioSessionPortHeadphones] ||
            [portType isEqualToString:AVAudioSessionPortBluetoothLE] ||
            [portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [portType isEqualToString:AVAudioSessionPortBluetoothA2DP])
            
            return YES;
        
    }
    return NO;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    NSInteger rate = YOYRecoderRate;
    if ([self.audioRecoderDelegate respondsToSelector:@selector(valueForAVSampleRateKey)]) {
        rate = [self.audioRecoderDelegate valueForAVSampleRateKey];
    }
    [dicM setObject:@(rate) forKey:AVSampleRateKey];
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    NSInteger bit = YOYRecoderBit;
    if ([self.audioRecoderDelegate respondsToSelector:@selector(valueForAVLinearPCMBitDepthKey)]) {
        bit = [self.audioRecoderDelegate valueForAVLinearPCMBitDepthKey];
    }
    [dicM setObject:@(bit) forKey:AVLinearPCMBitDepthKey];
    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
    return (NSDictionary *)dicM;
}

- (YOYCachePathManager *)pathManager{
    if (!_pathManager) {
        _pathManager = [YOYCachePathManager sharedCachePathManager];
    }
    return _pathManager;
}

- (AVAudioSession *)audioSession{
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
    }
    return _audioSession;
}

- (YOYAudioMixManager *)audioMixManager{
    if (!_audioMixManager) {
        _audioMixManager = [YOYAudioMixManager sharedAudioMixManager];
    }
    return _audioMixManager;
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer initTimerWithTimeInterval:1 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (AVAudioRecorder *)audioRecoder{
    if (_audioRecoder) {
        _audioRecoder.delegate = nil;
        _audioRecoder = nil;
    }
    NSString *savedPath = [self.pathManager savedPathForCafAudio];
    self.audioFilePath = savedPath;
    NSError *error;
    NSDictionary *setting = [self getAudioSetting];
    _audioRecoder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:savedPath] settings:setting error:&error];
    //开启音量检测
    _audioRecoder.meteringEnabled = YES;
    _audioRecoder.delegate = self;
    return _audioRecoder;
}

@end
