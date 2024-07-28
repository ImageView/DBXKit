//
//  UIView+dbx_clickedArea.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/07/27.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (dbx_clickedArea)

/// 点击区域扩展范围
@property (nonatomic, assign) UIEdgeInsets dbx_clickedAreaEdgeInsets;
/// 设置点击区域，并且直接生肖
/// 等同于clickedAreaEdgeInsets + dbx_enableExtendedClickedArea
- (void)dbx_enableExtendedClickedAreaEdgeInsets:(UIEdgeInsets)clickedAreaEdgeInsets;
/// 扩展点击区域生效
- (void)dbx_enableExtendedClickedArea;
/// 扩展点击区域失效
- (void)dbx_disableExtendedClickedArea;

@end

NS_ASSUME_NONNULL_END
