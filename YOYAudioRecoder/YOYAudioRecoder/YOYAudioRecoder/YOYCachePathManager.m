//
//  YOYCachePathManager.m
//  YOYAudioRecoder
//
//  Created by Tommy on 2018/9/26.
//  Copyright © 2018年 Tommy. All rights reserved.
//

#import "YOYCachePathManager.h"

@interface YOYCachePathManager()

/// 录音存放的沙盒路径-->文件目录
@property(nonatomic,copy)NSString *cachePath;

@end

@implementation YOYCachePathManager

#pragma mark 公有方法
/**
 创建该类的一个单例
 
 @return 单例
 */
+(YOYCachePathManager *)sharedCachePathManager{
    static YOYCachePathManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/**
 创建目录
 */
-(void)createCacheFileDirWithPath:(NSString *)path{
    /// 默认的存储路径
    _cachePath = [self defaultCachePath];
    if (path) {
        _cachePath = path;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = NO;
    if ([fileManager fileExistsAtPath:_cachePath isDirectory:&isDir]) {
        isExists = YES;
    }
    if ((!isDir)&&(!isExists)){
        [fileManager createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

/**
 移除录音文件-->保留文件夹,保留当天的录音文件
 */
-(void)removeAudioFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = NO;
    if ([fileManager fileExistsAtPath:_cachePath isDirectory:&isDir]) {
        isExists = YES;
    }
    if ((!isDir)&&(!isExists)){
        NSLog(@"沙盒中不存在该目录");
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *now = [NSDate date];
    NSString *partName = [dateFormatter stringFromDate:now];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:_cachePath];
    for (NSString *fileName in enumerator) {
        if (![fileName containsString:partName]) {
            [fileManager removeItemAtPath:[_cachePath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

/**
 移除RecodedAudio文件夹下的所有文件
 */
-(void)removeAllAudioFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = NO;
    if ([fileManager fileExistsAtPath:_cachePath isDirectory:&isDir]) {
        isExists = YES;
    }
    if ((!isDir)&&(!isExists)){
        NSLog(@"沙盒中不存在该目录");
        return;
    }
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:_cachePath];
    for (NSString *fileName in enumerator) {
        [fileManager removeItemAtPath:[_cachePath stringByAppendingPathComponent:fileName] error:nil];
    }
}

/**
 获取录音在沙盒中的存放位置(.caf格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForCafAudio{
    
    return [self savedPathWithType:@".caf"];
    
}

/**
 获取录音在沙盒中的存放位置(.m4a格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForM4aAudio{
    return [self savedPathWithType:@".m4a"];
}

/**
 获取录音在沙盒中的存放位置(.pcm格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForPCMAudio{
    return [self savedPathWithType:@".pcm"];
}

/**
 获取录音在沙盒中的存放位置(.mp3格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForMP3Audio{
    return [self savedPathWithType:@".mp3"];
}

/**
 获取录音在沙盒中的存放位置(.wav格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForWAVAudio{
    return [self savedPathWithType:@".wav"];
}

-(NSString *)savedPathWithType:(NSString *)type{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSDate *now = [NSDate date];
    NSString *prefixName = [dateFormatter stringFromDate:now];
    NSString *suffixName = type;
    NSString *fileName = [NSString stringWithFormat:@"%@%@",prefixName,suffixName];
    NSString *audioPath = [_cachePath stringByAppendingPathComponent:fileName];
    return audioPath;
    
}

#pragma mark 私有方法

-(NSString *)defaultCachePath{
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    libraryPath = [libraryPath stringByAppendingPathComponent:@"RecodedAudio"];
    return libraryPath;
}



@end
