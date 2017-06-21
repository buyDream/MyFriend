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

@interface RGMainViewController ()<TRRVoiceRecognitionManagerDelegate, UITextViewDelegate, RecordButtonDelegate>
@property (nonatomic, strong) TRRSpeechSythesizer *sythesizer;
@property (nonatomic, strong) TRRTuringAPIConfig  *apiConfig;

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (weak, nonatomic) IBOutlet RecordButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@end

@implementation RGMainViewController {
    TRRTuringRequestManager *apiRequest;
    BOOL chatState;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_configureView];
    [self p_initalizationTuring];
    self.voiceButton.delegate = self;
    self.voiceButton.recordHUDSuperView = self.view;

}

#pragma mark -- private method

- (void)p_initalizationTuring {
    self.sythesizer = [[TRRSpeechSythesizer alloc] initWithAPIKey:BaiduAPIKey secretKey:BaiduSecretKey];
    self.apiConfig = [[TRRTuringAPIConfig alloc] initWithAPIKey:TuringAPIKey];
    apiRequest = [[TRRTuringRequestManager alloc]
                                          initWithConfig:self.apiConfig];
//    TRRVoiceRecognitionManager *sharedInstance=[TRRVoiceRecognitionManager sharedInstance];
//    [sharedInstance setApiKey:BaiduAPIKey secretKey:BaiduSecretKey];
//    sharedInstance.delegate = self;
    
}

- (void)p_sendMessage:(NSString *)text {
    [_apiConfig request_UserIDwithSuccessBlock:^(NSString *userId) {
        NSLog(@"userId: %@", userId);
        [apiRequest request_OpenAPIWithInfo:text successBlock:^(NSDictionary *resultDic) {
            NSLog(@"resultDic: %@", resultDic);
            self.outputLabel.text = resultDic[@"text"];
            // add new
            if (!self.muteButton.selected) [self.sythesizer start:resultDic[@"text"]];
        } failBlock:^(TRRAPIErrorType errorType, NSString *infoStr) {
            NSLog(@"infoStr:%@, ", infoStr );
        }];
    } failBlock:^(TRRAPIErrorType errorType, NSString *infoStr) {
        
    }];
    
}

- (IBAction)startAutoChat:(UIButton *)sender {
    chatState = !chatState;
    self.voiceButton.enabled = !self.voiceButton.enabled;
    [sender setTitle:chatState ? @"关闭对话": @"对话" forState:UIControlStateNormal];
    self.inputTextView.text = chatState ? @"请开始你的表演" : @"";
}
- (IBAction)clickMutebutton:(UIButton *)sender {
    sender.selected = !sender.selected;
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


- (void)didReceiveResult:(NSString *)result {
    _inputTextView.text = result;
    [self p_sendMessage:result];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![_inputTextView isExclusiveTouch]) [_inputTextView resignFirstResponder];
}

@end
