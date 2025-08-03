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
@property(nonatomic, weak) id <UIScrollViewDelegate> scrollViewDelegate;

- (instancetype)initWithViewController:(UIViewController *)viewController;

- (void)reloadData;

// 刷新UI，适用于数据有新增或者删除的情况，只刷新增删的部分，其他cell不动，性能较高
- (void)performUpdatesAnimated:(BOOL)animated completion:(void (^)(BOOL finish))completion;
@end

NS_ASSUME_NONNULL_END
