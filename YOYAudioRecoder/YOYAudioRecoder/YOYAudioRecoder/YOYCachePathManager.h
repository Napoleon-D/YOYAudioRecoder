//
//  YOYCachePathManager.h
//  YOYAudioRecoder
//
//  Created by Tommy on 2018/9/26.
//  Copyright © 2018年 Tommy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YOYCachePathDelegate <NSObject>

@optional
/**
 用户自定义的录音文件存储路径
 
 @return 录音文件存储路径
 */
-(NSString *)cachePathForAudioRecoder;

@end

@interface YOYCachePathManager : NSObject

@property(nonatomic,assign)id<YOYCachePathDelegate>cachePathDelegate;

/**
 创建该类的一个单例

 @return 单例
 */
+(YOYCachePathManager *)sharedCachePathManager;

/**
 创建目录
 */
-(void)createCacheFileDir;

/**
 移除录音文件-->保留文件夹,保留当天的录音文件
 */
-(void)removeAudioFiles;

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

@end
