//
//  DBXARUtils.h
//  DBXKit
//
//  Created by asherluo on 2022/7/16.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXARUtils : NSObject


// 获取responder基于同类型在父视图的index
+ (NSInteger)dbx_itemIndexForResponder:(UIResponder *)responder;

// view在在父视图的节点
+ (NSString *)dbx_nodeOfView:(UIView *)view;

// view在vc里的路径
+ (NSString *)dbx_indexPathInCurrViewControllerOfView:(UIView *)view ;
@end

NS_ASSUME_NONNULL_END
