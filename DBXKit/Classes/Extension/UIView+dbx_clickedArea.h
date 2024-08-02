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

/// 扩展点击区域生效
- (void)dbx_enableExtendedClickedArea;
/// 扩展点击区域失效
- (void)dbx_disableExtendedClickedArea;

#pragma mark - 手动设定扩展的范围
/// 点击区域扩展范围
@property (nonatomic, assign) UIEdgeInsets dbx_clickedAreaEdgeInsets;
/// 设置点击区域，并且直接生效
/// 等同于clickedAreaEdgeInsets + dbx_enableExtendedClickedArea
- (void)dbx_enableExtendedClickedAreaEdgeInsets:(UIEdgeInsets)clickedAreaEdgeInsets;


#pragma mark - 设定点击区域最小尺寸，不够的自动补齐，跟dbx_clickedAreaEdgeInsets同时设置的话，优先dbx_clickedAreaEdgeInsets
///  交互区域的最小尺寸
@property (nonatomic, assign) CGSize dbx_autoFixMinSize;
/// 等同于dbx_autoFixMinSize + dbx_enableExtendedClickedArea
- (void)dbx_clickedAreaAutoFitMinSize:(CGSize)minSize;

@end

NS_ASSUME_NONNULL_END
