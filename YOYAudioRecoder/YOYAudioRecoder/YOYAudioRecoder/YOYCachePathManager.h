//
//  YOYCachePathManager.h
//  YOYAudioRecoder
//
//  Created by Tommy on 2018/9/26.
//  Copyright © 2018年 Tommy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YOYAudioRecoderHeader.h"

@interface YOYCachePathManager : NSObject

/**
 创建该类的一个单例

 @return 单例
 */
+(YOYCachePathManager *)sharedCachePathManager;

/**
 创建目录

 @param path 自定义沙盒目录，默认传nil，沙盒路径为NSLibraryDirectory中的RecodedAudio
 */
-(void)createCacheFileDirWithPath:(NSString *)path;

/**
 移除录音文件-->保留文件夹,保留当天的录音文件
 */
-(void)removeAudioFiles;

/**
 移除RecodedAudio文件夹下的所有文件
 */
-(void)removeAllAudioFiles;

/**
 获取录音在沙盒中的存放位置(.caf格式的文件全路径)

 @return 录音文件存在路径
 */
-(NSString *)savedPathForCafAudio;

/**
 获取录音在沙盒中的存放位置(.m4a格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForM4aAudio;

/**
 获取录音在沙盒中的存放位置(.pcm格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForPCMAudio;

/**
 获取录音在沙盒中的存放位置(.mp3格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForMP3Audio;

/**
 获取录音在沙盒中的存放位置(.wav格式的文件全路径)
 
 @return 录音文件存在路径
 */
-(NSString *)savedPathForWAVAudio;

@end
