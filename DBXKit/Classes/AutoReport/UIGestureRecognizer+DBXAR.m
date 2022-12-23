//
//  UIGestureRecognizer+DBXAR.m
//  DBXKit
//
//  Created by asherluo on 2022/7/31.
//  Copyright © 2022 DBX. All rights reserved.
//

#import "UIGestureRecognizer+DBXAR.h"
#import <objc/runtime.h>
#import "DBXARUtils.h"

// 手势的扩展
@implementation UIGestureRecognizer (DBXAR)

- (instancetype)dbx_initWithTarget:(id)target action:(SEL)action {
    [self dbx_initWithTarget:target action:action];
    [self removeTarget:target action:action];
    [self addTarget:target action:action];
    return self;
}

- (void)dbx_addTarget:(id)target action:(SEL)action {
    if (!self.dbx_gestureTarget) {
        self.dbx_gestureTarget = [DBXGestureTarget gesTureTargetWithGesture:self];
        self.dbx_gestureTarget.reportID = [DBXARUtils reportIDByTarget:target actionString:NSStringFromSelector(action)];
        if (self.dbx_gestureTarget) {
            [self dbx_addTarget:self.dbx_gestureTarget action:@selector(dbx_gestureAutoReport:)];
        }
    }
    [self dbx_addTarget:target action:action];
}

- (void)dbx_removeTarget:(id)target action:(SEL)action {
//    if (self.dbx_gestureTarget) {
//        [self dbx_removeTarget:self.dbx_gestureTarget action:@selector(dbx_gestureAutoReport:)];
//        self.dbx_gestureTarget = nil;
//    }
    [self dbx_removeTarget:target action:action];
}

static char kAssociatedObjectKey_dbx_gestureTarget;
- (void)setDbx_gestureTarget:(DBXGestureTarget *)dbx_gestureTarget {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dbx_gestureTarget, dbx_gestureTarget, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DBXGestureTarget *)dbx_gestureTarget{
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_dbx_gestureTarget);
}

@end
