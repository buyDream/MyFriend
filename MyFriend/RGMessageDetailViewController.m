//
//  RGMessageDetailViewController.m
//  MyFriend
//
//  Created by Refraining on 2017/6/21.
//  Copyright © 2017年 Refraining. All rights reserved.
//

#import "RGMessageDetailViewController.h"
#import <WebKit/WebKit.h>

static const CGFloat  kBarButtonItemSize = 30;

@interface RGMessageDetailViewController ()<WKUIDelegate, WKNavigationDelegate>
@property (nonatomic, strong) NSString *aUrl;
@property (nonatomic, strong) WKWebView *webView;
// 进程池
@property (nonatomic, strong) WKProcessPool *webProcessPool;
@end

@implementation RGMessageDetailViewController

- (instancetype)initWithUrl:(NSString *)urlString {

    if (self == [super init] ) {
        self.aUrl = urlString;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupViews];
    [self p_createNavi];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_aUrl]];
    [self.webView loadRequest:request];
}

#pragma mark -- WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.title = webView.title;

}

#pragma mark -- UI
- (void)p_setupViews {
    self.webView.backgroundColor = [UIColor colorWithRed:249.0 / 255 green:249 / 255.0 blue:249.0 / 255 alpha:1];
    self.webView.scrollView.backgroundColor = self.webView.backgroundColor;
    self.webView.scrollView.scrollEnabled = YES;
    self.webView.scrollView.bouncesZoom = NO;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
}
- (void)p_createNavi {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame= CGRectMake(0, 0, kBarButtonItemSize, kBarButtonItemSize);
    [btn setImage:[UIImage imageNamed:@"nav_leftarrow"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(p_webViewBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn_left = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,btn_left,nil];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationController.navigationBar.barTintColor = TINTCOLOR;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:17],NSFontAttributeName,nil]];
    self.navigationController.navigationBar.translucent = YES;
}

// 返回
- (void)p_webViewBack {
    if ([_webView canGoBack]) {
        [self.webView goBack];
    } else  {
//        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@" !!!!!!!!!message detail vc dismiss!!!!!!");
        }];
    }
}

#pragma mark -- lazy load
- (WKProcessPool *)webProcessPool {
    if (!_webProcessPool) {
        WKProcessPool * pool = [[WKProcessPool alloc]init];
        _webProcessPool = pool;
    }
    return _webProcessPool;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        config.preferences = [[WKPreferences alloc]init];
        //设置进程池
        config.processPool = self.webProcessPool;
        config.preferences.minimumFontSize = 10;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
//        [config.userContentController addScriptMessageHandler:self name:@"interOp"];
        _webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:config];
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}


@end
