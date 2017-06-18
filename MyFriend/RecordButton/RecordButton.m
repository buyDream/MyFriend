
//
//  RecordButton.m
//  TChat
//
//  Created by hujiqing on 15-12-21.
//  Copyright (c) 2015年 Sinosun Technology Co., Ltd. All rights reserved.
//

#import "XHVoiceRecordHUD.h"
#import "RecordButton.h"
#import "TRecordAudio.h"
#import "TPlayAudio.h"

#import "TRRVoiceRecognitionManager.h"

#define kXHTouchDownToRecord @"按住 说话"
#define kXHTouchUpToFinish @"松开 结束"

@interface RecordButton () <TRecordAudioDelegate, TRRVoiceRecognitionManagerDelegate> {
    BOOL isSubmit;
    CGFloat _duration;
    BOOL isShow;
    TRRVoiceRecognitionManager *voiceInstance;
}
@property(nonatomic, strong) NSString *recordPath;
//@property(nonatomic, retain) TRecordAudio *voice;
@property (nonatomic, strong) XHVoiceRecordHUD  *recordHUDView;
@property (nonatomic, assign) BOOL  isValid;
@property(nonatomic, assign) NSTimeInterval updateTime; // 控制列表刷新频率

@property (nonatomic) int clickCount;


@end

@implementation RecordButton

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
        self.clickCount = 1;
    }
    return self;
}

- (void)dealloc {
//    self.voice.delegate = nil;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)stopRecord
{
    [self   holdDownButtonTouchUpOutside];
//    self.voice.delegate = nil;
}

- (void)setup {
    self.isValid = NO;
    self.updateTime = 0;
    [self addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
    [self setTitle:kXHTouchDownToRecord forState:UIControlStateNormal];
}

//按下按钮开始录音
- (void)holdDownButtonTouchDown {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"showACoverNaviButton" object:nil];
    if ([[NSDate date] timeIntervalSince1970] - self.updateTime < 1) {
        self.isValid = NO;
        return;
    }
    self.updateTime = [[NSDate date] timeIntervalSince1970];
    self.isValid = YES;
    self.clickCount++;
    int count = self.clickCount;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (count != self.clickCount) {
                return ;
            }
            if (available) {
                [[TPlayAudio sharedManager] stop];
                _duration = 0;
                if (self.recordHUDView != nil) {
                    [self.recordHUDView removeFromSuperview];
                    self.recordHUDView = nil;
                }
                
                if (isShow == NO) {
                    self.recordHUDView = [[UINib nibWithNibName:@"XHVoiceRecordHUD" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil].lastObject;
                    isShow = YES;
                }
                
                [self.recordHUDView startRecordingHUDAtView:self.recordHUDSuperView];
                NSLog(@"self.recordHUDView startRecordingHUDAtView:self.recordHUDSuperView");
                isSubmit = NO;
                //开始录音
//                if (self.voice != nil) {
//                    if (self.voice.isRecording) {
//                        [self.voice stop];
//                    }
//                    self.voice = nil;
//                }
//                self.voice = [[TRecordAudio alloc] init];
//                self.voice.delegate = self;
//                [self.voice start];
                [self setTitle:kXHTouchUpToFinish forState:UIControlStateNormal];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"麦克风被禁用" message:@"请在iPhone的“设置-隐私-麦克风”中允许T信访问你的麦克风" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                });
            }
        }];
    }
    
    
    //add new
    voiceInstance = [TRRVoiceRecognitionManager sharedInstance];
    [voiceInstance setApiKey:BaiduAPIKey secretKey:BaiduSecretKey];
    voiceInstance.delegate = self;
    NSArray *array = @[@(20000)];
    voiceInstance.recognitionPropertyList = array;
    int startStatus = [voiceInstance startVoiceRecognition];
    if (startStatus != 0) {
        NSLog(@"err %d", startStatus);
//        _recognizeResultTextView.text = [NSString stringWithFormat:@"err = %i", startStatus ];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[[UIAlertView alloc] initWithTitle:@"麦克风被禁用" message:@"请在iPhone的“设置-隐私-麦克风”中允许T信访问你的麦克风" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
//        });
    }
    
    
    
}

//手指向上滑动松开取消录音
- (void)holdDownButtonTouchUpOutside {
    if (!self.isValid) {
        return;
    }
    self.clickCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideACoverNaviButton" object:nil];
//    [[SSLogManager sharedManager] writeSuccessLog:@"手指向上滑动后松开取消录音"];
    isSubmit = NO;
    if (self.recordHUDView != nil) {
        typeof(self) __weak weakSelf = self;
        [self.recordHUDView cancelRecordCompled:^(BOOL fnished) {
            isShow = NO;
            weakSelf.recordHUDView = nil;
        }];
    }
//    if (self.voice.recorder.isRecording) {
//        [self.voice stop];
//    }
    [self setTitle:kXHTouchDownToRecord forState:UIControlStateNormal];
    
    // add new
    [voiceInstance cancleRecognize];
}

//松开手指完成录音
- (void)holdDownButtonTouchUpInside {
    if (!self.isValid) {
        return;
    }
    self.clickCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideACoverNaviButton" object:nil];

    isSubmit = YES;
    NSLog(@"手指松开完成录音");
    if (self.recordHUDView != nil) {
        NSLog(@"recordHUDView != nil");
        typeof(self) __weak weakSelf = self;
        [self.recordHUDView cancelRecordCompled:^(BOOL fnished) {
            weakSelf.recordHUDView = nil;
            isShow = NO;
            NSLog(@"recordHUDView = nil");
        }];
//        if (self.voice.recorder.isRecording) {
//            [self.voice stop];
//        }else{
//            if ([self.delegate respondsToSelector:@selector(didTAudioView:duration:)]) {
//                [self.delegate didTAudioView:self.recordPath duration:_duration > MAXDURATION ? MAXDURATION : _duration];
//            }
//        }
    }
    
    [self setTitle:kXHTouchDownToRecord forState:UIControlStateNormal];
}

//按住滑动到按钮范围外
- (void)holdDownDragOutside {
    if (!self.isValid) {
        return;
    }
    [self.recordHUDView resaueRecord];
    [self setTitle:kXHTouchDownToRecord forState:UIControlStateNormal];
    
}

//按住滑动到按钮范围内
- (void)holdDownDragInside {
    if (!self.isValid) {
        return;
    }
    [self.recordHUDView pauseRecord];
    [self setTitle:kXHTouchUpToFinish forState:UIControlStateNormal];
    
}

#pragma mark -  TRecordAudioDelegate
#pragma mark -

- (void)didRecordAudio:(NSString *)audioPath {
//    self.recordPath = [[AppPath userCachePath:[[SSAppManager sharedManager].loginUser.UAId stringValue]] stringByAppendingString:audioPath.lastPathComponent];
//    if (self.recordPath.length < 1) {
//        return;
//    }
//    [[NSFileManager defaultManager] copyItemAtPath:audioPath toPath:self.recordPath error:nil];
//    if (isSubmit) { //发送录音
//        [[SSLogManager sharedManager] writeSuccessLog:[NSString stringWithFormat:@"完成录音发送--%@",audioPath]];
//        if ([self.delegate respondsToSelector:@selector(didTAudioView:duration:)]) {
//            [self.delegate didTAudioView:self.recordPath duration:_duration > MAXDURATION ? MAXDURATION : _duration];
//        }
//    } else {
//        [[SSLogManager sharedManager] writeLog:@"录音超过限制时长"];
//        //        [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
//    }
//    isSubmit = NO;
    
}

- (void)recordVoiceProgress:(float)voiceProgress recordTime:(NSTimeInterval)currentTime {
//    _duration = currentTime > MAXDURATION ? MAXDURATION : currentTime;
    //    NSString *string = [NSString stringWithFormat:@"%02li:%02li",
    //                        lround(floor(currentTime / 60.)) % 60,
    //                        lround(floor(currentTime/1.)) % 60];
    [self.recordHUDView configRecordingWithPeakPower:voiceProgress recordTime:currentTime];
}

//录音结束后移除录音UI
-(void)recordAudioFinish{
    if (self.recordHUDView != nil) {
        typeof(self) __weak weakSelf = self;
        [self.recordHUDView cancelRecordCompled:^(BOOL fnished) {
            weakSelf.recordHUDView = nil;
        }];
    }
//    if (self.voice.recorder.isRecording) {
//        [self.voice stop];
//    }
    [self setTitle:kXHTouchDownToRecord forState:UIControlStateNormal];
}


#pragma mark -- TRRVoiceRecognitionManagerDelegate
- (void)onRecognitionResult:(NSString *)result {
//    _recognizeResultTextView.text = result;
    NSLog(@"result = %@", result);
    NSString *resultStr;
    if (!result || [result isEqualToString:@""]) {
        resultStr = @"未检测到说话";
    }
    if ([self.delegate respondsToSelector:@selector(didReceiveResult:)]) {
        [self.delegate didReceiveResult:result];
    }
}

- (void)onRecognitionError:(NSString *)errStr {
//    _recognizeResultTextView.text = NSLocalizedString(errStr, nil);
    NSLog(@"Error = %@", errStr);
}

- (void)onStartRecognize {
//    _recognizeResultTextView.text = @"正在语音识别，请讲话";
    NSLog(@"正在语音识别，请讲话");
}

- (void)onSpeechStart {
//    _recognizeResultTextView.text = @"检测到已说话";
    NSLog(@"检测到已说话");
}

- (void)onSpeechEnd {
//    _recognizeResultTextView.text = @"检测到已停止说话";
    NSLog(@"检测到已停止说话");
}



@end
