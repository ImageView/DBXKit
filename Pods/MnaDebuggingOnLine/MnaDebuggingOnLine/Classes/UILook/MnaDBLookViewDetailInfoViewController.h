//
//  MnaDBLookViewDetailInfoViewController.h
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/12/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MnaDBLookViewDetailInfoViewController;
@protocol MnaDBLookViewDetailInfoViewControllerDelegate <NSObject>

- (void)lookViewDetailInfoViewController:(MnaDBLookViewDetailInfoViewController *)vc didShowSelectedView:(UIView *)view;

@end
// UI检查工具详细信息
@interface MnaDBLookViewDetailInfoViewController : UITableViewController
// 代理
@property(nonatomic, weak) id <MnaDBLookViewDetailInfoViewControllerDelegate> delegate;

// 目标对象
@property(nonatomic, strong) NSObject *targetObject;

// 目标对象的类级别
@property(nonatomic, strong) Class targetClass;

// 目标的name
@property(nonatomic, copy) NSString *targetName;

@end

// UI检查工具详细信息Cell
@interface MnaAdjustsTextTableViewCell : UITableViewCell
// 文本
@property (nonatomic, strong) UILabel *txtLabel;

@end
NS_ASSUME_NONNULL_END
