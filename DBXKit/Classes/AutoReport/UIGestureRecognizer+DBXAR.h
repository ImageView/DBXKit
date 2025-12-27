//
//  UIGestureRecognizer+DBXAR.h
//  DBXKit
//
//  Created by 调包侠 on 2022/7/31.
//  Copyright © 2022 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBXGestureTarget.h"

NS_ASSUME_NONNULL_BEGIN

// 手势的扩展
@interface UIGestureRecognizer (DBXAR)
// 额外的点击事件
@property (nonatomic, strong) DBXGestureTarget *dbx_gestureTarget;

- (instancetype)dbx_initWithTarget:(id)target action:(SEL)action;

- (void)dbx_addTarget:(id)target action:(SEL)action;

- (void)dbx_removeTarget:(id)target action:(SEL)action;
@end

NS_ASSUME_NONNULL_END
