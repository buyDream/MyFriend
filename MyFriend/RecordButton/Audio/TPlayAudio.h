//
//  TPlayAudio.h
//  HHAudio
//
//  Created by WH1408003 on 14-9-10.
//  Copyright (c) 2014年 WH1407055. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TPlayAudioProtocol <NSObject>

@property (nonatomic, assign) BOOL isPlaying;       // 是否正在播放
// 路径文件的路径
- (NSString *)audioPath;

@end

@protocol TPlayAudioDelegate <NSObject>

// 完成播放
- (void)finishedPlayRecord;
@optional
// 播放执行中
//- (void)playerRecordProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;

@end

@interface TPlayAudio : NSObject

@property(nonatomic, strong) id <TPlayAudioDelegate> delegate;   // 强引用，由该类自行管理

+ (TPlayAudio *)sharedManager;

- (void)playAudio:(id <TPlayAudioProtocol>)audioPath delegate:(id <TPlayAudioDelegate>)delegate;
- (void)stop;

@end


