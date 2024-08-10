//
//  DBXTrackTarget.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

// 追踪的目标
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ConditionBlock)(SEL selector);
typedef void(^BeforeInvocateBlock)(id target, SEL sel, NSArray *args);
typedef void(^AfterInvocateBlock)(id target, SEL sel, NSArray *args, id returnValue);

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


// 关联对象，用来把target跟DBXTrackTarget关联起来
//@property(nonatomic, strong, readonly) DBXTrackAssociatedObj *accociatedObj;

// 存储届时调用的selector的真实实现
+ (SEL)aliasSelector:(SEL)selector;

- (void)createAccociateObject;
- (DBXTrackAssociatedObj *)accociatedObj;

@end

@interface DBXTrackAssociatedObj : NSObject

@property(nonatomic, strong) DBXTrackTarget *targetModel;

@end

NS_ASSUME_NONNULL_END
