//
//  DBXDebounce.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/22.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DBXDebounceModel) {
    DBXDebounceModelFirstOnly,  // 只执行第一个，后面的丢掉
    DBXDebounceModelLastOnly,   // 只执行最后一个，前面的丢掉
    DBXDebounceModelDebounce,   // 发送消息后延迟一段时间执行，如果继续发送消息，会重新计时
};

@class DBXDebounceDealloc;
// 防抖规则
@interface DBXDebounceRule : NSObject
// 规则生效的对象
@property(nonatomic, weak) id target;
// 防抖sel
@property(nonatomic, assign) SEL selector;
// 防抖间隔
@property(nonatomic, assign) NSTimeInterval debounceInterval;
// 防抖模式
@property(nonatomic, assign) DBXDebounceModel model;
// 执行队列
@property (nonatomic) dispatch_queue_t queue;
// 规则是否生效
@property(nonatomic, assign, readonly, getter=isActive) BOOL active;

- (void)apply;
//- (DBXDebounceDealloc *)deallocObj;
//
//- (void)clearDeallocObj;

@end



@interface DBXDebounce : NSObject

+ (instancetype)sharedInstance;

- (BOOL)applyRule:(DBXDebounceRule *)rule;

- (BOOL)discardRule:(DBXDebounceRule *)rule;
@end

NS_ASSUME_NONNULL_END
