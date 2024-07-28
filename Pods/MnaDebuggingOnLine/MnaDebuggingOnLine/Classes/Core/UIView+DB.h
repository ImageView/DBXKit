//
//  UIView+DB.h
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/11/7.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// UIView支持拖拽
@interface UIView (DB)
// 点击回调
@property(nullable, nonatomic, copy) __kindof UIView * (^db_hitTestBlock)(CGPoint point, UIEvent *event, __kindof UIView *originalView);

- (void)allowFollow;

// 当前所在VC
- (UIViewController *)dbx_viewController;

@end

NS_ASSUME_NONNULL_END
