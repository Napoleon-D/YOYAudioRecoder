//
//  ViewController.m
//  YOYAudioRecoder
//
//  Created by Tommy on 2018/9/26.
//  Copyright © 2018年 Tommy. All rights reserved.
//

#import "ViewController.h"
#import "YOYAudioRecoderHeader.h"
#import "YOYAudioRecoder.h"

@interface ViewController ()<YOYAudioRecoderDelegate>

@property(nonatomic,strong)YOYAudioRecoder *audioRecoder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"录音器";
    
    UIButton *startRecoderBtn = [[UIButton alloc] initWithFrame:CGRectMake((UIScreen.mainScreen.bounds.size.width - 150)*0.5f, 100, 150, 40)];
    startRecoderBtn.layer.borderWidth = 1;
    startRecoderBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [startRecoderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startRecoderBtn setTitle:@"开始录音" forState:UIControlStateNormal];
    [startRecoderBtn addTarget:self action:@selector(startRecoderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startRecoderBtn];
    
    UIButton *pauseRecoderBtn = [[UIButton alloc] initWithFrame:CGRectMake((UIScreen.mainScreen.bounds.size.width - 150)*0.5f, CGRectGetMaxY(startRecoderBtn.frame) + 20, 150, 40)];
    pauseRecoderBtn.layer.borderWidth = 1;
    pauseRecoderBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [pauseRecoderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pauseRecoderBtn setTitle:@"暂停录音" forState:UIControlStateNormal];
    [pauseRecoderBtn addTarget:self action:@selector(pauseRecoderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseRecoderBtn];
    
    UIButton *resumeRecoderBtn = [[UIButton alloc] initWithFrame:CGRectMake((UIScreen.mainScreen.bounds.size.width - 150)*0.5f, CGRectGetMaxY(pauseRecoderBtn.frame) + 20, 150, 40)];
    resumeRecoderBtn.layer.borderWidth = 1;
    resumeRecoderBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [resumeRecoderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [resumeRecoderBtn setTitle:@"继续录音" forState:UIControlStateNormal];
    [resumeRecoderBtn addTarget:self action:@selector(resumeRecoderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resumeRecoderBtn];
    
    UIButton *stopRecoderBtn = [[UIButton alloc] initWithFrame:CGRectMake((UIScreen.mainScreen.bounds.size.width - 150)*0.5f, CGRectGetMaxY(resumeRecoderBtn.frame) + 20, 150, 40)];
    stopRecoderBtn.layer.borderWidth = 1;
    stopRecoderBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [stopRecoderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [stopRecoderBtn setTitle:@"停止录音" forState:UIControlStateNormal];
    [stopRecoderBtn addTarget:self action:@selector(stopRecoderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopRecoderBtn];
    
}

-(void)startRecoderBtnClicked:(UIButton *)sender{
    NSLog(@"开始录音");
    [self.audioRecoder startAudioRecoder];
}

-(void)pauseRecoderBtnClicked:(UIButton *)sender{
    NSLog(@"暂停录音");
    [self.audioRecoder pauseAudioRecoder];
}

-(void)resumeRecoderBtnClicked:(UIButton *)sender{
    NSLog(@"继续录音");
    [self.audioRecoder resumeAudioRecoder];
}

-(void)stopRecoderBtnClicked:(UIButton *)sender{
    NSLog(@"停止录音");
    [self.audioRecoder stopAudioRecoder];
}

- (YOYAudioRecoder *)audioRecoder{
    if (!_audioRecoder) {
        _audioRecoder = [YOYAudioRecoder sharedAudioRecoder];
        _audioRecoder.audioRecoderDelegate = self;
    }
    return _audioRecoder;
}

#pragma mark YOYAudioRecoderDelegate

/**
 音频的录制时间-->1s执行一次
 
 @param time 当前录制的总时间
 */
-(void)recodingForTime:(NSTimeInterval)time{
    NSLog(@"当前的总时间：%f",time);
}

/**
 完成录制的回调
 
 @param error 错误
 @param audioPath 录音的文件沙盒路径
 @param totalTime 录音的总时间
 */
-(void)didFinishedAudioRecoderWithError:(NSError *)error audioPath:(NSString *)audioPath totalTime:(NSTimeInterval)totalTime{
    
    if (error) {
        NSLog(@"录制出错");
    }else{
        NSLog(@"最终路径:%@",audioPath);
        NSLog(@"最终时间:%f",totalTime);
    }
    
}

@end
