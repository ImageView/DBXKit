//
//  DBXTrackTarget.h
//  DBXKit
//
//  Created by 调包侠 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

// 追踪的目标
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ConditionBlock)(SEL _Nonnull selector);
typedef void(^BeforeInvocateBlock)(id _Nonnull target, SEL _Nonnull sel, NSArray  * _Nullable args);
typedef void(^AfterInvocateBlock)(id _Nonnull target, SEL _Nonnull sel, NSArray * _Nullable args, id _Nullable returnValue);

extern const NSString *kDBXTrackAccociatedObjKey;

@class DBXTrackAssociatedObj;
// 跟踪的任务
@interface DBXTrackTarget : NSObject

// 跟踪的真实目标
@property(nonatomic, weak) id target;
// 决定某个sel是否需要追踪
@property(nonatomic, copy) ConditionBlock conditionBlock;
// 在方法调用前的回调
@property(nonatomic, copy) BeforeInvocateBlock beforeBlock;
// 在方法调用前的回调
@property(nonatomic, copy) AfterInvocateBlock afterBlock;

// 存储届时调用的selector的真实实现
+ (SEL)aliasSelector:(SEL)selector;

- (void)createAccociateObject;

// 关联对象，用来把target跟DBXTrackTarget关联起来
- (DBXTrackAssociatedObj *)accociatedObj;

@end

@interface DBXTrackAssociatedObj : NSObject

@property(nonatomic, strong) DBXTrackTarget *targetModel;
@property (nonatomic) Class cls;

- (void)lock;
- (void)unlock;

@end

NS_ASSUME_NONNULL_END
