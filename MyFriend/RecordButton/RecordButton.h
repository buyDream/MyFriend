//
//
//  RecordButton.h
//  TChat
//
//  Created by hujiqing on 15-12-21.
//  Copyright (c) 2015年 Sinosun Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHVoiceRecordHUD.h"

@protocol RecordButtonDelegate <NSObject>
@required
/**
 *    录音完成时调用
 *
 *    @param audioPath 录音的路径
 *    @param duration  录音的时长
 */
-(void)didTAudioView:(NSString*)audioPath duration:(NSTimeInterval)duration;

- (void)didReceiveResult:(NSString *)result;
@end

@interface RecordButton : UIButton
@property (nonatomic, weak) id <RecordButtonDelegate> delegate;

@property (nonatomic, weak) UIView              *recordHUDSuperView; // 将HUD显示在哪个view上

- (void)stopRecord;

@end
