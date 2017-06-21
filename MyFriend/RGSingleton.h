//
//  RGSingleton.h
//  MyFriend
//
//  Created by Refraining on 2017/6/21.
//  Copyright © 2017年 Refraining. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface RGSingleton : NSObject

@end

@interface RGVoiceRecongitonInstance : NSObject
/*
 初始化配置，单例
 */

+ (RGVoiceRecongitonInstance *)shareVioceRecognInstance;

@end


