//
//  YOYAudioQueueManager.m
//  MSCDemo
//
//  Created by Tommy on 2018/9/29.
//

#define QUEUE_BUFFER_SIZE 3      // 输出音频队列缓冲个数
#define kDefaultBufferDurationSeconds 3
#define kDefaultSampleRate 8000   //定义采样率为16000

#import "YOYAudioQueueManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "YOYCachePathManager.h"

@interface YOYAudioQueueManager(){
    AudioQueueRef _audioQueue;                          //输出音频播放队列
    AudioStreamBasicDescription _recordFormat;
    AudioQueueBufferRef _audioBuffers[QUEUE_BUFFER_SIZE]; //输出音频缓存
}

@property(nonatomic,strong)NSMutableData *totalData;

@property(nonatomic,copy)NSString *filePath;


@end

extern NSString * const ESAIntercomNotifationRecordString;
static BOOL isRecording = NO;

@implementation YOYAudioQueueManager

-(instancetype)init{
    if (self = [super init]) {
        
        //重置下
        memset(&_recordFormat, 0, sizeof(_recordFormat));
        _recordFormat.mSampleRate = kDefaultSampleRate;
        _recordFormat.mChannelsPerFrame = 1;
        _recordFormat.mFormatID = kAudioFormatLinearPCM;
        
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        _recordFormat.mBitsPerChannel = 16;
        _recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
        _recordFormat.mFramesPerPacket = 1;
        
        //初始化音频输入队列
        AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
        
        //计算估算的缓存区大小
        int frames = (int)ceil(kDefaultBufferDurationSeconds * _recordFormat.mSampleRate);
        int bufferByteSize = frames * _recordFormat.mBytesPerFrame;
        
        NSLog(@"缓存区大小%d",bufferByteSize);
        
        //创建缓冲器
        for (int i = 0; i < QUEUE_BUFFER_SIZE; i++){
            AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
            AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
        }
        
    }
    return self;
}

-(void)startRecording
{
    // 开始录音
    if (!isRecording) {
        
        AudioQueueStart(_audioQueue, NULL);
        isRecording = YES;
        
    }
    
}

-(void)stopRecording
{
    if (isRecording)
    {
        isRecording = NO;
        
        //停止录音队列和移除缓冲区,以及关闭session，这里无需考虑成功与否
        AudioQueueStop(_audioQueue, true);
        //移除缓冲区,true代表立即结束录制，false代表将缓冲区处理完再结束
        AudioQueueDispose(_audioQueue, true);
    }
}

#pragma mark 获取录音实时流的回调

static void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    if (inNumPackets > 0) {
        YOYAudioQueueManager *manager = (__bridge YOYAudioQueueManager*)inUserData;
        [manager processAudioBuffer:inBuffer withQueue:inAQ];
    }
    
    if (isRecording) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

- (void)processAudioBuffer:(AudioQueueBufferRef )audioQueueBufferRef withQueue:(AudioQueueRef )audioQueueRef
{
    NSMutableData * dataM = [NSMutableData dataWithBytes:audioQueueBufferRef->mAudioData length:audioQueueBufferRef->mAudioDataByteSize];
    
//    NSLog(@"总的数数据：%@",dataM);
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if (![defaultManager fileExistsAtPath:self.filePath]) {
        [defaultManager createFileAtPath:self.filePath contents:nil attributes:nil];
    }
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    
    if (!_totalData) {
        _totalData = [NSMutableData dataWithData:dataM];
    }else{
        [_totalData appendData:dataM];
    }
    
    [fileHandler writeData:_totalData];
    
//    if ([self.delegate respondsToSelector:@selector(didGetAudioResponseData:)]) {
//        [self.delegate didGetAudioResponseData:_totalData];
//    }
    
}

- (NSString *)filePath{
    if (!_filePath) {
        _filePath = [[YOYCachePathManager sharedCachePathManager] savedPathForPCMAudio];
    }
    return _filePath;
}

@end
