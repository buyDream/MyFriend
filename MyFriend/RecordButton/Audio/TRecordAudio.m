//
//  TRecordAudio.m
//  HHAudio
//
//  Created by WH1408003 on 14-8-20.
//  Copyright (c) 2014年 Sinosun Technology Co., Ltd. All rights reserved.
//

#import "TRecordAudio.h"
#import "VoiceConverter.h"
#import "TPlayAudio.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TRecordAudio () <AVAudioRecorderDelegate> {
    NSTimer *timer;
}

@property(nonatomic, retain) NSString *recordPath; //录音路径
@property(retain, nonatomic) VoiceConverter *recorderVC;

@end

@implementation TRecordAudio

- (void)start {
    [[TPlayAudio sharedManager] stop];
    NSError *err = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&err];
    
    if (err) {
        return;
    }
//    [audioSession setActive:YES error:&err];

    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
    err = nil;
    if (err) {
        return;
    }
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey]; //   kAudioFormatMPEG4AAC
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];            // 16000.0
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDate *time = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddhhmmssSSS";
    NSString *timeNow = [dateFormatter stringFromDate:time];
//    dateFormatter.dateFormat = @"SSS";
//    timeNow = [[dateFormatter stringFromDate:time] stringByAppendingString:timeNow];
    //	self.recordPath = [NSString stringWithFormat:@"%@/%@.pcm", strUrl,timeNow];//pcm
    self.recordPath = [NSString stringWithFormat:@"%@/%@.wav", strUrl, timeNow];
    self.recordPath =  [self.recordPath stringByReplacingOccurrencesOfString:@":" withString:@""];
//    [[SSLogManager sharedManager] writeSuccessLog:[NSString stringWithFormat:@"开始录音创建文件%@",self.recordPath]];
    NSURL *url = [NSURL fileURLWithPath:self.recordPath];
    
    err = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&err];
    if (audioData) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&err];
    }
    err = nil;
    if (self.recorder) {
        [self.recorder stop];
        self.recorder = nil;
    }
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    self.recorder.delegate = self;
    self.isRecording = YES;
    if (!_recorder) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [_recorder prepareToRecord];
    
//    if ([_recorder prepareToRecord] == YES){
//        [_recorder record];
//    }else {
//        int errorCode = CFSwapInt32HostToBig ([err code]);
//        NSLog(@"Error: %@ [%4.4s])" , [err localizedDescription], (char*)&errorCode);
//    }
    _recorder.meteringEnabled = YES;
    [_recorder recordForDuration:(NSTimeInterval)MAXDURATION];
    
    [self resetTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.16 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
  

}
- (void)stop {
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
}
#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    self.isRecording = NO;
    [self resetTimer];
    self.recorder = nil;
    
    if ([self.delegate respondsToSelector:@selector(didRecordAudio:)]) {
        [self wavToAmr];
        [self.delegate didRecordAudio:self.recordPath];
    }
}

#pragma mark - wav转amr
- (void)wavToAmr {
    
    NSRange range = [self.recordPath rangeOfString:@".wav"];
    if (range.length > 0) {
        
        NSString *amrPath = [self.recordPath substringToIndex:range.location];
        NSLog(@"amrPath:%@", amrPath);
        amrPath = [amrPath stringByAppendingString:@".amr"];
        //转格式
        [VoiceConverter wavToAmr:self.recordPath amrSavePath:amrPath];
        self.recordPath = amrPath;
    }
}

#pragma mark - Timer Update

- (void)updateMeters {
    if (_recorder) {
        [_recorder updateMeters];
    }
    
    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    
    if ((self.recorder != nil) && (self.recorder.isRecording == YES)) {
        if ([self.delegate respondsToSelector:@selector(recordVoiceProgress:recordTime:)]) {
            [self.delegate recordVoiceProgress:lowPassResults recordTime:self.recorder.currentTime];
        }
    }
}

- (BOOL)isRecording {
    if (self.recorder) {
        return self.recorder.recording;
    }
    return NO;
}

- (void)resetTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}




@end
