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

@interface RGMainViewController ()<TRRVoiceRecognitionManagerDelegate, UITextViewDelegate>
@property (nonatomic, strong) TRRSpeechSythesizer *sythesizer;
@property (nonatomic, strong) TRRTuringAPIConfig  *apiConfig;

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (weak, nonatomic) IBOutlet RecordButton *voiceButton;

@end

@implementation RGMainViewController {
    TRRTuringRequestManager *apiRequest;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_configureView];
    [self p_initalizationTuring];
   
}


- (void)p_initalizationTuring {
    self.sythesizer = [[TRRSpeechSythesizer alloc] initWithAPIKey:BaiduAPIKey secretKey:BaiduSecretKey];
    self.apiConfig = [[TRRTuringAPIConfig alloc] initWithAPIKey:TuringAPIKey];
    apiRequest = [[TRRTuringRequestManager alloc]
                                          initWithConfig:self.apiConfig];
    TRRVoiceRecognitionManager *sharedInstance=[TRRVoiceRecognitionManager sharedInstance];
    [sharedInstance setApiKey:BaiduAPIKey secretKey:BaiduSecretKey];
    sharedInstance.delegate = self;
    
}

- (void)p_sendMessage:(NSString *)text {
    [_apiConfig request_UserIDwithSuccessBlock:^(NSString *userId) {
        NSLog(@"userId: %@", userId);
        [apiRequest request_OpenAPIWithInfo:text successBlock:^(NSDictionary *resultDic) {
            NSLog(@"resultDic: %@", resultDic);
            self.outputLabel.text = resultDic[@"text"];
        } failBlock:^(TRRAPIErrorType errorType, NSString *infoStr) {
            NSLog(@"infoStr:%@, ", infoStr );
        }];
    } failBlock:^(TRRAPIErrorType errorType, NSString *infoStr) {
        
    }];

    
}


#pragma mark -- TRRVoiceRecognitionManagerDelegate
- (void)onRecognitionResult:(NSString *)result {}
- (void)onRecognitionError:(NSString *)errStr {}
- (void)onStartRecognize {}
- (void)onSpeechStart {}
- (void)onSpeechEnd {}


#pragma mark -- private metho
- (void)p_configureView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.outputLabel.text = @"您好，我是技师refrainGo，来自深圳！";
    self.inputTextView.layer.cornerRadius = 5;
    self.inputTextView.layer.borderColor = [UIColor greenColor].CGColor;
    self.inputTextView.layer.masksToBounds = YES;
    self.inputTextView.layer.borderWidth = 2;
    self.inputTextView.returnKeyType = UIReturnKeySend;
    self.inputTextView.enablesReturnKeyAutomatically = YES;
    self.inputTextView.delegate = self;
}

#pragma mark -- UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {

    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    // 如果输入了回车，则发送结果
    if ([text isEqualToString:@"\n"]) {
        [self p_sendMessage:textView.text];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![_inputTextView isExclusiveTouch]) {
        [_inputTextView resignFirstResponder];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end