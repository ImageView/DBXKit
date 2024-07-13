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

typedef NS_ENUM(NSInteger, DBXDebounceShouldInvote) {
    DBXDebounceShouldInvoteInRule,          // 按规则执行
    DBXDebounceShouldInvoteIgnoreRule,      // 立即执行，忽略规则
    DBXDebounceShouldNotInvote              // 不执行
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
/**
 是否马上执行消息
 block 的参数列表可选，返回值为 DBXDebounceShouldInvote 类型。
 block 传入的第一个参数为 `DBXDebounceRule`，其余参数列表与消息调用的参数列表相同
 block 如果返回 YES，则消息立即执行
 */
@property (nonatomic) id shouldInvokeImmediatelyBlock;
// 执行队列
@property (nonatomic) dispatch_queue_t queue;
// 规则是否生效
@property(nonatomic, assign, readonly, getter=isActive) BOOL active;

- (instancetype)initWithTarget:(id)target selector:(SEL)selector debounceInterval:(NSTimeInterval)debounceInterval NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)apply;
- (void)discard;
//- (DBXDebounceDealloc *)deallocObj;
//
//- (void)clearDeallocObj;

@end



@interface DBXDebounce : NSObject

+ (instancetype)sharedInstance;


/// 注册规则
/// - Parameter rule: 注册具体的规则，返回YES表示注册成功，NO表示之前已经有注册过了
- (BOOL)applyRule:(DBXDebounceRule *)rule;


/// 注销规则
/// - Parameter rule: 返回YES表示注销成功，NO表示需要保留相关类的hook
- (BOOL)discardRule:(DBXDebounceRule *)rule;
@end

//@interface NSObject (<#category name#>)
//
//@end
NS_ASSUME_NONNULL_END
