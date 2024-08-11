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
/// ⚠️同一个target只第一次调用有效⚠️
/// - Parameters:
///   - target: 要追踪的实例或者对象，如果是实例会创建一个派生类
///   - conditionBlock: 具体某个函数是否需要追踪
///   - beforeBlock: 函数调用前响应
///   - afterBlock: 函数调用后响应
///
///   Return 是否正在追踪
+ (BOOL)dbx_trackTarget:(id)target
                 condition:(ConditionBlock)conditionBlock
                    before:(BeforeInvocateBlock)beforeBlock
                     after:(AfterInvocateBlock)afterBlock;
@end

NS_ASSUME_NONNULL_END
