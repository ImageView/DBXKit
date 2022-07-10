//
//  UIView+DBXInteract.h
//  DBXKit
//
//  Created by asherluo on 2022/7/10.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (DBXInteract)

// 允许连续点击的最低间隔，默认0
@property(nonatomic, assign) NSTimeInterval dbx_minTimeIntervalAfterLastClick;
// 上次点击的时间
@property(nonatomic, assign) NSTimeInterval dbx_timeIntervalLastClick;

@end

NS_ASSUME_NONNULL_END
