//
//  BaseNavigationViewController.m
//  HiBrain
//
//  Created by ly on 15/11/9.
//  Copyright © 2015年 ly. All rights reserved.  
//

#import "BaseNavigationViewController.h"

@interface BaseNavigationViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation BaseNavigationViewController

//+ (void)initialize{
//    [[UINavigationBar appearance] setBackgroundImage:[UIImageUtil imageWithColor:TINTCOLOR] forBarMetrics:UIBarMetricsDefault];
//    
//    [[UINavigationBar appearance] setBarTintColor:TINTCOLOR];
//    
//    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImageUtil imageWithColor:TINTCOLOR]];
//    
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationBar.barTintColor = TINTCOLOR;
    self.navigationBar.tintColor = [UIColor whiteColor];
//    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor],NSForegroundColorAttributeName,
                                                [UIFont systemFontOfSize:17],NSFontAttributeName,
                                                nil]];

}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
