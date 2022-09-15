//
//  UIView+DBXCore.m
//  DBXKit
//
//  Created by asherluo on 2022/7/10.
//  Copyright © 2022 DBX. All rights reserved.
//

#import "UIView+DBXCore.h"
#import <objc/runtime.h>
#import "DBXViewUtils.h"

@implementation UIView (DBXCore)

static char kAssociatedObjectKey_dbx_vc;
- (void)setDbx_vc:(UIViewController *)dbx_vc {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dbx_vc, dbx_vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)dbx_vc {
    UIViewController *vc = objc_getAssociatedObject(self, &kAssociatedObjectKey_dbx_vc);
    if (!vc) {
        vc = [DBXViewUtils dbx_getViewController:self];
        self.dbx_vc = vc;
    }
    return vc;
}

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
