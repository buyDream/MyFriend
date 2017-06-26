//
//  RGMainViewController.m
//  MyFriend
//
//  Created by Refraining on 2017/6/11.
//  Copyright © 2017年 Refraining. All rights reserved.
//

#import "RGMainViewController.h"

#import "TRRTuringAPIConfig.h"
#import "TRRSpeechSythesizer.h"
#import "TRRVoiceRecognitionManager.h"
#import "RecordButton.h"
#import "TRRTuringRequestManager.h"
#import "RGMessageDetailViewController.h"

#import "BaseNavigationViewController.h"
@interface RGMainViewController () <UITextViewDelegate, RecordButtonDelegate>
@property (nonatomic, strong) TRRSpeechSythesizer *sythesizer;
@property (nonatomic, strong) TRRTuringAPIConfig  *apiConfig;

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (weak, nonatomic) IBOutlet RecordButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation RGMainViewController {
    TRRTuringRequestManager *apiRequest;
    BOOL chatState;
    NSString *_messageText;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_configureView];
    [self p_initalizationTuring];
    self.voiceButton.delegate = self;
    self.voiceButton.recordHUDSuperView = self.view;

}

#pragma mark -- 按钮点击事件
- (IBAction)startAutoChat:(UIButton *)sender {
    chatState = !chatState;
    self.voiceButton.enabled = !self.voiceButton.enabled;
    [sender setTitle:chatState ? @"关闭对话": @"对话" forState:UIControlStateNormal];
    self.inputTextView.text = chatState ? @"请开始你的表演" : @"";
}
// 静音按钮

- (IBAction)clickMutebutton:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) [self.sythesizer stop];
}

- (IBAction)checkDetailMessage:(UIButton *)sender {
//    // 进入自定义view
//    RGMessageDetailViewController *detailVC = [[RGMessageDetailViewController alloc] initWithUrl:_messageText];
//    BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:detailVC];
//    [self.navigationController pushViewController:detailVC animated:YES];
//    [self presentViewController:nav animated:YES completion:^{
//        NSLog(@"YOU COME IN");
//        self.inputTextView.text = @"";
//
//    }];
//     进入Safari
    NSString *iTunesLink = _messageText;
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]]; // iOS 10 抛弃
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink] options:nil completionHandler:^(BOOL success) {
        NSLog(@"what it is ?");
    }];
    
}

#pragma mark -- private method
- (void)p_initalizationTuring {
    self.sythesizer = [[TRRSpeechSythesizer alloc] initWithAPIKey:BaiduAPIKey secretKey:BaiduSecretKey];
    self.apiConfig = [[TRRTuringAPIConfig alloc] initWithAPIKey:TuringAPIKey];
    apiRequest = [[TRRTuringRequestManager alloc]
                  initWithConfig:_apiConfig];
    //    TRRVoiceRecognitionManager *sharedInstance=[TRRVoiceRecognitionManager sharedInstance];
    //    [sharedInstance setApiKey:BaiduAPIKey secretKey:BaiduSecretKey];
    //    sharedInstance.delegate = self;
    
}

- (void)p_sendMessage:(NSString *)text {
    WEAKSELF;
    [_apiConfig request_UserIDwithSuccessBlock:^(NSString *userId) {
        NSLog(@"userId: %@", userId);
        [apiRequest request_OpenAPIWithInfo:text successBlock:^(NSDictionary *resultDic) {
            NSLog(@"resultDic: %@", resultDic);
            STRONGSELF;
            [strongSelf p_parseResult:resultDic];
            //            apiRequest = nil;
            /*令实例变量不再引用apiRequest
             （想多了，只要在TRRTuringRequestManager里实现完成块的事件后，不再保留块即可避免循环引用）
             并且如果这样设计的话，还会导致，apiRequest无法多次使用
             */
        } failBlock:^(TRRAPIErrorType errorType, NSString *infoStr) {
            NSLog(@"infoStr:%@, ", infoStr );
        }];
    } failBlock:^(TRRAPIErrorType errorType, NSString *infoStr) {
        
    }];
    
}

- (void)p_parseResult:(NSDictionary *)resultDic {
    if (resultDic[@"text"]) {
        self.outputLabel.text = resultDic[@"text"];
        // add new
        if (!_muteButton.selected) [_sythesizer start:resultDic[@"text"]];
    }
    
    // 如果有详细信息，则展示
    if (resultDic[@"url"]) {
        _messageText = resultDic[@"url"];
        self.messageLabel.text = _messageText;
        self.skipButton.hidden = NO;
    } else {
        self.skipButton.hidden = YES;
        self.messageLabel.text = @"";
    }
}

- (void)p_configureView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.outputLabel.text = @"您好，技师refrainGo，为您服务！";
    self.inputTextView.layer.cornerRadius = 5;
    self.inputTextView.layer.borderColor = [UIColor greenColor].CGColor;
    self.inputTextView.layer.masksToBounds = YES;
    self.inputTextView.layer.borderWidth = 2;
    self.inputTextView.returnKeyType = UIReturnKeySend;
    self.inputTextView.enablesReturnKeyAutomatically = YES;
    self.inputTextView.delegate = self;
}

#pragma mark -- UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    // 如果输入了回车，则发送结果
    if ([text isEqualToString:@"\n"]) {
        [self p_sendMessage:textView.text];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark -- RecordButtonDelegate
- (void)didReceiveResult:(NSString *)result {
    _inputTextView.text = result;
    [self p_sendMessage:result];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![_inputTextView isExclusiveTouch]) [_inputTextView resignFirstResponder];
}

@end
