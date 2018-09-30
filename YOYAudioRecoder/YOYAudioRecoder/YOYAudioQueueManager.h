//
//  YOYAudioQueueManager.h
//  MSCDemo
//
//  Created by Tommy on 2018/9/29.
//

#import <Foundation/Foundation.h>

@protocol YOYAudioQueueManagerDelegate <NSObject>

-(void)didGetAudioResponseData:(NSData *)data;

@end

@interface YOYAudioQueueManager : NSObject

@property(nonatomic,assign)id<YOYAudioQueueManagerDelegate>delegate;

/**
 开始录制
 */
-(void)startRecording;

/**
 结束u录制
 */
-(void)stopRecording;

@end
