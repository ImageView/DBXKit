//
//  DBXListAdapter.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBXListAdapterDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXListAdapter : NSObject

// 数据代理
@property(nonatomic, weak) id <DBXListAdapterDataSource> dataSource;
// 本适配器的VC
@property(nonatomic, weak) UIViewController *viewController;
// 视图
@property(nonatomic, weak, nullable) UICollectionView *collectionView;
// collectionView原代理
@property(nonatomic, weak) id <UICollectionViewDelegate> collectionViewDelegate;
// scollerView原代理
@property(nonatomic, weak) id <UIScrollViewDelegate> scrollerViewDelegate;

- (instancetype)initWithViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
