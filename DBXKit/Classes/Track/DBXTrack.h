//
//  DBXTrack.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXTrackTarget.h"

NS_ASSUME_NONNULL_BEGIN


@interface DBXTrack : NSObject

/// 追踪某个对象的函数调用
/// ⚠️1.同一个target只第一次调用有效
/// ⚠️2.有可变参数的方法用NSInvocation调用会丢失后面的参数，因此这类方法要用condition屏蔽掉，避免方法调用出问题
/// ⚠️3.追踪了类的实例就不能再追踪类本身了，因为追踪实例会创建一个子类，子类跟父类无法同时追踪
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
@end

NS_ASSUME_NONNULL_END
