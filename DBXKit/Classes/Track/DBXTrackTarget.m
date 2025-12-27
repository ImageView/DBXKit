//
//  DBXTrackTarget.m
//  DBXKit
//
//  Created by 调包侠 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXTrackTarget.h"
#import <objc/runtime.h>
#import <pthread.h>
#import "DBXCore.h"

const NSString *kDBXTrackAccociatedObjKey = @"kDBXTrackAccociatedObjKey";

// 追踪的目标
@implementation DBXTrackTarget

+ (SEL)aliasSelector:(SEL)selector {
    NSString *aliasSelectorName = [NSString stringWithFormat:@"%@track_%@", kDBXHookMethodPrefix, NSStringFromSelector(selector)];
    SEL aliasSelector = NSSelectorFromString(aliasSelectorName);
    return aliasSelector;
}

- (void)createAccociateObject {
    if (!self.target) {
        return;
    }
    DBXTrackAssociatedObj *accObj = objc_getAssociatedObject(self.target, &kDBXTrackAccociatedObjKey);
    if (!accObj) {
        accObj = [[DBXTrackAssociatedObj alloc] init];
        accObj.targetModel = self;
        objc_setAssociatedObject(self.target, &kDBXTrackAccociatedObjKey, accObj, OBJC_ASSOCIATION_RETAIN);
    }
}

- (DBXTrackAssociatedObj *)accociatedObj {
    if (!self.target) {
        return nil;
    }
    DBXTrackAssociatedObj *accObj = objc_getAssociatedObject(self.target, &kDBXTrackAccociatedObjKey);
    if (!accObj) {
        accObj = objc_getAssociatedObject(object_getClass(self.target), &kDBXTrackAccociatedObjKey);
    }
    return accObj;
}

@end

@interface DBXTrackAssociatedObj ()
// 操作类的锁
@property(nonatomic, assign) pthread_mutex_t invokeLock;
@end

@implementation DBXTrackAssociatedObj

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_invokeLock, &attr);
    }
    return self;
}

- (void)lock {
    pthread_mutex_lock(&_invokeLock);
}

- (void)unlock {
    pthread_mutex_unlock(&_invokeLock);
}

@end
