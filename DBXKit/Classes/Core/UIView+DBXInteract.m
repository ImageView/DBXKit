//
//  UIView+DBXInteract.m
//  DBXKit
//
//  Created by asherluo on 2022/7/10.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "UIView+DBXInteract.h"
#import <objc/runtime.h>

@implementation UIView (DBXInteract)

static char kAssociatedObjectKey_dbx_minTimeIntervalAfterLastClick;
- (void)setDbx_minTimeIntervalAfterLastClick:(NSTimeInterval)dbx_minTimeIntervalAfterLastClick {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dbx_minTimeIntervalAfterLastClick, @(dbx_minTimeIntervalAfterLastClick), OBJC_ASSOCIATION_ASSIGN);
}

- (NSTimeInterval)dbx_minTimeIntervalAfterLastClick {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_dbx_minTimeIntervalAfterLastClick) doubleValue];
}

static char kAssociatedObjectKey_dbx_timeIntervalLastClick;
- (void)setDbx_timeIntervalLastClick:(NSTimeInterval)dbx_timeIntervalLastClick {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dbx_timeIntervalLastClick, @(dbx_timeIntervalLastClick), OBJC_ASSOCIATION_ASSIGN);
}

- (NSTimeInterval)dbx_timeIntervalLastClick {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_dbx_timeIntervalLastClick) doubleValue];
}

@end
