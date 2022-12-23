//
//  UIView+DBXCore.h
//  DBXKit
//
//  Created by asherluo on 2022/7/10.
//  Copyright © 2022 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// view相关功能
@interface UIView (DBXCore)

// 所在的VC，使用频率较高，加个属性是为了缓存下来
@property(nonatomic, strong) UIViewController *dbx_vc;
// 允许连续点击的最低间隔，默认0
@property(nonatomic, assign) NSTimeInterval dbx_minTimeIntervalAfterLastClick;
// 上次点击的时间
@property(nonatomic, assign) NSTimeInterval dbx_timeIntervalLastClick;

@end

NS_ASSUME_NONNULL_END
