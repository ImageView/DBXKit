//
//  DBXTrackTarget.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXTrackTarget.h"
#import <objc/runtime.h>

const NSString *kDBXTrackAccociatedObjKey = @"kDBXTrackAccociatedObjKey";

// 追踪的目标
@implementation DBXTrackTarget

+ (SEL)aliasSelector:(SEL)selector {
    NSString *aliasSelectorName = [NSString stringWithFormat:@"__dbx_track_%@", NSStringFromSelector(selector)];
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

@implementation DBXTrackAssociatedObj



@end
