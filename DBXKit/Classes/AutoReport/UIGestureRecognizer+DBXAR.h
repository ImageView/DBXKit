//
//  UIGestureRecognizer+DBXAR.h
//  DBXKit
//
//  Created by asherluo on 2022/7/31.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBXGestureTarget.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (DBXAR)
// 额外的点击事件
@property (nonatomic, strong) DBXGestureTarget *dbx_gestureTarget;

- (instancetype)dbx_initWithTarget:(id)target action:(SEL)action;

- (void)dbx_addTarget:(id)target action:(SEL)action;

- (void)dbx_removeTarget:(id)target action:(SEL)action;
@end

NS_ASSUME_NONNULL_END
