//
//  UIView+DBXAR.m
//  DBXKit
//
//  Created by asherluo on 2022/7/16.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "UIView+DBXAR.h"
#import "DBXARUtils.h"
#import <objc/runtime.h>


@implementation UIView (DBXAR)

//static char kAssociatedObjectKey_dbx_vc;
//- (void)setDbx_vc:(UIViewController *)dbx_vc {
//    objc_setAssociatedObject(self, &kAssociatedObjectKey_dbx_vc, dbx_vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (UIViewController *)dbx_vc {
//    UIViewController *vc = objc_getAssociatedObject(self, &kAssociatedObjectKey_dbx_vc);
//    if (!vc) {
//        vc = [DBXARUtils dbx_getViewController:self];
//        self.dbx_vc = vc;
//    }
//    return vc;
//}

static char kAssociatedObjectKey_dbx_reportID;
- (void)setDbx_reportID:(NSString *)dbx_reportID {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dbx_reportID, dbx_reportID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)dbx_reportID {
    NSString *reportID = objc_getAssociatedObject(self, &kAssociatedObjectKey_dbx_reportID);
    if (!reportID) {
        reportID = [DBXARUtils dbx_targetActionOfView:self];
        self.dbx_reportID = reportID;
        //    defaultID = [DBXARUtils dbx_indexPathInCurrViewControllerOfView:self]
    }
    return reportID;
}

@end
