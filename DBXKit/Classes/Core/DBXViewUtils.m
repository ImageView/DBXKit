//
//  DBXViewUtils.m
//  DBXKit
//
//  Created by 调包侠 on 2022/7/23.
//  Copyright © 2022 DBX. All rights reserved.
//

#import "DBXViewUtils.h"
// 视图工具类
@implementation DBXViewUtils

// 获取view所在的viewController
+ (UIViewController *)dbx_getViewController:(UIView *)view {
    UIResponder *responder = view;
    while ((responder = responder.nextResponder)) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

@end
