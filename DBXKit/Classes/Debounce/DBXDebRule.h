//
//  DBXDebRule.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/24.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DBXDebounceModel) {
    DBXDebounceModelFirstOnly,  // 只执行第一个，后面的丢掉
    DBXDebounceModelLastOnly,   // 只直行最后一个，前面的丢掉
    DBXDebounceModelSerialAll   // 串行执行，上一个结束后debounceInterval秒后执行下一个
};

// 防抖规则
@interface DBXDebRule : NSObject

// 规则生效的对象
@property(nonatomic, weak) id target;
// 防抖sel
@property(nonatomic, assign) SEL selector;
// 防抖间隔
@property(nonatomic, assign) NSTimeInterval debounceInterval;
// 防抖模式
@property(nonatomic, assign) DBXDebounceModel model;
// 规则是否生效
@property(nonatomic, assign, readonly, getter=isActive) BOOL active;
@end

NS_ASSUME_NONNULL_END
