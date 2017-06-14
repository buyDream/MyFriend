//
//  TRecordAudio.h
//  HHAudio
//
//  Created by WH1408003 on 14-8-20.
//  Copyright (c) 2014年 Sinosun Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol TRecordAudioDelegate <NSObject>
/**
 *  录音完成时调用
 *
 *  @param audioPath 录音的路径
 */
- (void)didRecordAudio:(NSString *)audioPath;

/**
 *  获取录音的时间和音量的大小
 *
 *  @param voiceProress 音量的大小
 *  @param currentTime  录制的时间
 */

@optional
- (void)recordVoiceProgress:(float)voiceProress recordTime:(NSTimeInterval)currentTime;

@end

@interface TRecordAudio : NSObject

@property(nonatomic) BOOL isRecording;
@property(nonatomic, strong) AVAudioRecorder *recorder;

@property(nonatomic, assign) id<TRecordAudioDelegate> delegate;

-(void) start;
-(void) stop;  //结束录音

@end
