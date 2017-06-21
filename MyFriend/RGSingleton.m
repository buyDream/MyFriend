//
//  RGSingleton.m
//  MyFriend
//
//  Created by Refraining on 2017/6/21.
//  Copyright © 2017年 Refraining. All rights reserved.
//

#import "RGSingleton.h"

#import "TRRVoiceRecognitionManager.h"
@implementation RGSingleton

//+ (TRRVoiceRecognitionManager *)shareVioceRecognInstance {
//
//    static TRRVoiceRecognitionManager
//    
//}

@end

@implementation RGVoiceRecongitonInstance

+ (RGVoiceRecongitonInstance *)shareVioceRecognInstance {

    static RGVoiceRecongitonInstance *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[RGVoiceRecongitonInstance alloc] init];
    });
    return shareInstance;
    
}

@end
