//
//  DBXTrack.h
//  DBXKit
//
//  Created by 调包侠 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXTrackTarget.h"

NS_ASSUME_NONNULL_BEGIN


@interface DBXTrack : NSObject

/// 追踪某个对象的函数调用
/// ⚠️1.同一个target只第一次调用有效
/// ⚠️2.有可变参数的方法用NSInvocation调用会丢失后面的参数，因此这类方法要用condition屏蔽掉，避免方法调用出问题
/// ⚠️3.如果某个class和其一个实例都追踪了，优先走实例的追踪
/// ⚠️4.如果要忽略追踪直接执行selector，如在before/after中，请使用dbx_performSelectorUnTracked:来执行
/// ⚠️5.直接监听class比较危险，因为会修改被监听的class的不少实现，最好尽量监听实例
/// - Parameters:
///   - target: 要追踪的实例或者对象，如果是实例会创建一个派生类
///   - conditionBlock: 具体某个函数是否需要追踪
///   - beforeBlock: 函数调用前响应
///   - afterBlock: 函数调用后响应
///
///   Return 是否正在追踪
+ (BOOL)dbx_trackTarget:(id _Nonnull)target
                 condition:(ConditionBlock _Nullable)conditionBlock
                    before:(BeforeInvocateBlock _Nullable)beforeBlock
                     after:(AfterInvocateBlock _Nullable)afterBlock;

/// 便捷的看日志
+ (BOOL)dbx_trackTargetForLog:(id _Nonnull)target
                    condition:(ConditionBlock _Nullable)conditionBlock
                  logCallBack:(void (^)(NSString *afterlog))logBlock;
@end

@interface NSObject (DBXTrack)

/// 躲过监听的执行某个selector
/// 如在before/after里执行被追踪的函数时sel1，执行sel1又会进入before/after，因而会无限递归，因此要用以下方法来调用sel1，避免递归问题
- (_Nullable id)dbx_performSelectorUnTracked:(SEL _Nonnull)selector;
- (_Nullable id)dbx_performSelectorUnTracked:(SEL _Nonnull)selector withArguments:(void *_Nullable)firstArgument, ... NS_REQUIRES_NIL_TERMINATION;

// 常用日志模板
+ (NSString *)dbx_trackStringWithFormate:(NSString *)formate
                                  target:(id)target
                                     sel:(SEL)sel
                                    args:(NSArray *)args
                             returnValue:(id)returnValue;
@end

NS_ASSUME_NONNULL_END
