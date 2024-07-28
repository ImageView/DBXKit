//
//  MnaDebugging.h
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/11/6.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 对外接口
@interface MnaDebugging : NSObject

+ (instancetype)sharedInstance;

// 设置初始化的起始位置
+ (void)beginAtPoint:(CGPoint)point;

+ (void)show;

+ (void)hide;

@end

NS_ASSUME_NONNULL_END
