
//  XHVoiceRecordHUD.h
//  TChat
//
//  Created by hujiqing on 15-12-21.
//  Copyright (c) 2015年 Sinosun Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHVoiceRecordHUD : UIView


/**
 *  开始显示录音HUD控件在某个view
 *
 *  @param view 具体要显示的View
 */
- (void)startRecordingHUDAtView:(UIView *)view;

/**
 *  提示取消录音
 */
- (void)pauseRecord;

/**
 *  提示继续录音
 */
- (void)resaueRecord;

/**
 *  停止录音，意思是完成录音
 *
 *  @param compled 完成录音后的block回调
 */
- (void)stopRecordCompled:(void(^)(BOOL fnished))compled;

/**
 *  取消录音
 *
 *  @param compled 取消录音完成后的回调
 */
- (void)cancelRecordCompled:(void(^)(BOOL fnished))compled;

- (void)configRecordingWithPeakPower:(CGFloat)peakPower recordTime:(NSTimeInterval)currentTime;


@end
