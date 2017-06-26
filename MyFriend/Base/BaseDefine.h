//
//  BaseDefine.h
//  MyFriend
//
//  Created by Refraining on 2017/6/21.
//  Copyright © 2017年 Refraining. All rights reserved.
//

#ifndef BaseDefine_h
#define BaseDefine_h


//全局主题颜色
#define TINTCOLOR [UIColor colorWithRed:44/255.0 green:174/255.0 blue:177/255.0 alpha:1]
#define WEAKSELF __weak typeof(self)weakSelf = self
#define STRONGSELF __strong typeof(weakSelf)strongSelf = weakSelf

#ifdef DEBUG
#   define RGLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define RGLog(...)
#endif
#endif /* BaseDefine_h */
