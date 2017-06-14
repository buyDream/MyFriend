//
//  TPlayAudio.m
//  HHAudio
//
//  Created by WH1408003 on 14-9-10.
//  Copyright (c) 2014年 WH1407055. All rights reserved.
//

#import "TPlayAudio.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"
//#import "AppManager.h"
#import <UIKit/UIKit.h>
@interface TPlayAudio () <AVAudioPlayerDelegate>

@property (nonatomic, strong) VoiceConverter *recorderVC;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) id<TPlayAudioProtocol> myPlayAuto;
@property (nonatomic, strong) NSString *audioPath;

@end

@implementation TPlayAudio

CRManager(TPlayAudio);

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
}

- (void)sensorVoiceStateChange:(NSNotificationCenter *)note {
    if ([[UIDevice currentDevice] proximityState]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)setSystemVoiceConfig
{
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [audioSession setActive:YES error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

#pragma mark -

- (void)playAudio:(id<TPlayAudioProtocol>)audioProtocol delegate:(id<TPlayAudioDelegate>)delegate
{
    // 停止播放上一个录音
    [self   stop];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorVoiceStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];

    
    // 保存播放的数据
    self.delegate = delegate;
    self.myPlayAuto = audioProtocol;
    self.audioPath = [audioProtocol audioPath];
    
    // 数据转换
    [self amrToWav];

    // 开始播放
    [self   setSystemVoiceConfig];
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];

    [self.myPlayAuto setIsPlaying:YES];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[self audioPath]] error:nil];
    self.audioPlayer.numberOfLoops = 0;
    self.audioPlayer.delegate = self;
    self.audioPlayer.volume = 1.0;
    self.audioPlayer.pan = 0.0;
    //默认情况下扬声器播放
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.audioPlayer play];
    
    // 检测异常
    if(self.audioPlayer == nil || [self.myPlayAuto audioPath].length == 0) {
        [self   stop];
    }
}



#warning ------------调试警告-----------------MYS修改---- 通话语音测试-----------
- (void)stop{
    
    // 如果是通话在开启，程序音频不关闭
//    if ([AppManager shareManager].isCallBusy == NO) {
        if (self.audioPlayer != nil) {
            // 停止播放
            [self.audioPlayer stop];
        }
            [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        self.audioPlayer = nil;
        // 修改播放状态，不在播放中
        [self.myPlayAuto setIsPlaying:NO];
        self.myPlayAuto = nil;
        // 回调
        if ([self.delegate respondsToSelector:@selector(finishedPlayRecord)]) {
            [self.delegate finishedPlayRecord];
        }
        self.delegate = nil;
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
//        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
//    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // 停止播放
    [self   stop];

}

#pragma mark - amr转wav

- (void)amrToWav {
    NSRange range = [self.audioPath rangeOfString:@".amr"];
    if (range.length > 0) {
        NSString *amrPath = [self.audioPath substringToIndex:range.location];
        NSLog(@"amrPath:%@", amrPath);
        amrPath = [amrPath stringByAppendingString:@".wav"];
        //转格式
        [VoiceConverter amrToWav:self.audioPath wavSavePath:amrPath];
        self.audioPath = amrPath;
    }
}

@end

