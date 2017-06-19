//
//  XHVoiceRecordHUD.m
//  TChat
//
//  Created by hujiqing on 15-12-21.
//  Copyright (c) 2015年 Sinosun Technology Co., Ltd. All rights reserved.
//

#import "XHVoiceRecordHUD.h"

@interface XHVoiceRecordHUD ()

@property(nonatomic, weak) IBOutlet UILabel *remindLabel;
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *cancelRecordImageView;
@property(nonatomic, weak) IBOutlet UIImageView *recordingHUDImageView;
@property(nonatomic, weak) IBOutlet UIView *bgView;


@end

@implementation XHVoiceRecordHUD



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

//配置默认参数
- (void)setup {
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 10;
    self.remindLabel.layer.masksToBounds = YES;
    self.remindLabel.layer.cornerRadius = 4;
    self.remindLabel.backgroundColor = [UIColor clearColor];
  
//    [self.noUserButton bringSubviewToFront:]
}

- (void)startRecordingHUDAtView:(UIView *)view {
    self.frame = view.bounds;
//    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
//    self.center = center;
    [view addSubview:self];
    [self configRecoding:YES];
}

- (void)pauseRecord {
    [self configRecoding:YES];
    self.remindLabel.backgroundColor = [UIColor clearColor];
    self.remindLabel.text = @"手指上滑 取消录音";
}

- (void)resaueRecord {
    [self configRecoding:NO];
    self.remindLabel.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:82 / 255.0 blue:65 / 255.0 alpha:1.0];
    self.remindLabel.text = @"松开手指 取消录音";
}

- (void)stopRecordCompled:(void (^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)cancelRecordCompled:(void (^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

//逐渐消失自身
- (void)dismissCompled:(void (^)(BOOL fnished))compled {
    [UIView animateWithDuration:0.3
        delay:0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
            self.alpha = 0.0;
        }
        completion:^(BOOL finished) {
            [super removeFromSuperview];
            compled(finished);
        }];
}

//配置是否正在录音，需要隐藏和显示某些特殊的控件
- (void)configRecoding:(BOOL)recording {
    self.recordingHUDImageView.hidden = !recording;
    self.cancelRecordImageView.hidden = recording;
}

- (void)configRecordingWithPeakPower:(CGFloat)peakPower recordTime:(NSTimeInterval)currentTime {
    
    CGFloat duration = currentTime > MAXDURATION ? MAXDURATION : currentTime;
    
    if (MAXDURATION-currentTime < 10) {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = [NSString stringWithFormat:@"%.0f” ",MAXDURATION-duration];
    }else{
        self.timeLabel.hidden = YES;
    }
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

//根据语音输入的大小来配置需要显示的HUD图片
//根据语音输入的大小来配置需要显示的HUD图片
- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower {
    NSString *imageName = @"icon_Record_default";
    
    
    if (peakPower >= 0 && peakPower <= 0.066) {
        imageName = [imageName stringByAppendingString:@"1"];
    } else if (peakPower > 0.066 && peakPower <= 0.066*2) {
        imageName = [imageName stringByAppendingString:@"2"];
    } else if (peakPower > 0.066*2 && peakPower <= 0.066*3) {
        imageName = [imageName stringByAppendingString:@"3"];
    } else if (peakPower > 0.066*3 && peakPower <= 0.066*4) {
        imageName = [imageName stringByAppendingString:@"4"];
    } else if (peakPower > 0.066*4 && peakPower <= 0.066*5) {
        imageName = [imageName stringByAppendingString:@"5"];
    } else if (peakPower > 0.066*5 && peakPower <= 0.066*6) {
        imageName = [imageName stringByAppendingString:@"6"];
    } else if (peakPower > 0.066*6 && peakPower <= 0.066*7) {
        imageName = [imageName stringByAppendingString:@"7"];
    } else if (peakPower > 0.066*7 && peakPower <= 0.066*8) {
        imageName = [imageName stringByAppendingString:@"8"];
    } else if (peakPower > 0.066*8 && peakPower <= 0.066*9) {
        imageName = [imageName stringByAppendingString:@"9"];
    } else if (peakPower > 0.066*9 && peakPower <= 0.066*10) {
        imageName = [imageName stringByAppendingString:@"10"];
    } else if (peakPower > 0.066*10 && peakPower <= 0.066*11) {
        imageName = [imageName stringByAppendingString:@"11"];
    } else if (peakPower > 0.066*11 && peakPower <= 0.066*12) {
        imageName = [imageName stringByAppendingString:@"12"];
    } else if (peakPower > 0.066*12 && peakPower <= 0.066*13) {
        imageName = [imageName stringByAppendingString:@"13"];
    } else if (peakPower > 0.066*13 && peakPower <= 0.066*14) {
        imageName = [imageName stringByAppendingString:@"14"];
    } else if (peakPower > 0.066*14 && peakPower <= 1) {
        imageName = [imageName stringByAppendingString:@"15"];
    }
    self.recordingHUDImageView.image = [UIImage imageNamed:imageName];
}




@end
