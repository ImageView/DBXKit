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

//static char kAssociatedObjectKey_dbx_customIdentifier;
//- (void)setDbx_customIdentifier:(NSString *)dbx_customIdentifier {
//    objc_setAssociatedObject(self, &kAssociatedObjectKey_dbx_customIdentifier, dbx_customIdentifier, OBJC_ASSOCIATION_COPY);
//}
//
//- (NSString *)dbx_customIdentifier {
//    return objc_getAssociatedObject(self, &kAssociatedObjectKey_dbx_customIdentifier);
//}

static char kAssociatedObjectKey_dbx_reportID;
- (void)setDbx_reportID:(NSString *)dbx_reportID {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dbx_reportID, dbx_reportID, OBJC_ASSOCIATION_COPY);
}

- (NSString *)dbx_reportID {
    NSString *reportID = objc_getAssociatedObject(self, &kAssociatedObjectKey_dbx_reportID);
    return reportID ? : [DBXARUtils dbx_indexPathInCurrViewControllerOfView:self];
}

@end
