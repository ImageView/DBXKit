//
//  DBXListSectionController.h
//  DBXKit
//
//  Created by 调包侠 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBXListCollectionContext.h"
#import "DBXListSupplementaryViewSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXListSectionController : NSObject

/** collectionView上下文
 sectionController不持有collectionView实例本身，避免循环引用，因此这里用代理的方式把需要涉及collectionView实例的内容移交回adapter（adapter中有collectionView实例）去处理
 ⚠️内部处理，外部不能修改，直接使用即可
 */
@property(nonatomic, weak, readonly) id <DBXListCollectionContext> collectionViewContext;
// 所在控制器
@property(nonatomic, weak, readonly) UIViewController *viewController;
// 补充视图的代理，需要用到补充视图时设置代理并且实现，不在内部实现
@property(nonatomic, weak) id <DBXListSupplementaryViewSource> supplementaryViewSource;
// 数据对象
@property(nonatomic, strong) id object;
// 所在section
@property(nonatomic, assign, readonly) NSInteger section;
// inset
@property(nonatomic, assign) UIEdgeInsets inset;
@property(nonatomic, assign) CGFloat minimumLineSpacing;
@property(nonatomic, assign) CGFloat minimumInteritemSpacing;

#pragma mark - override method(需要子类继承并实现的方法，对应UICollectionViewDataSource、UICollectionViewDegate的代理方法)
/**
 UICollectionViewDataSource
 */
// 本section的item数
- (NSInteger)numberOfItems;

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item;

/**
 UICollectionViewDegate
 */
- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)kind;

- (void)didSelectItemAtItem:(NSInteger)item;

- (void)didDeselectItemAtItem:(NSInteger)item;

- (void)didHighlightItemAtItem:(NSInteger)item;

- (void)didUnhighlightItemAtItem:(NSInteger)item;

- (BOOL)shouldSelectItemAtItem:(NSInteger)item;

- (BOOL)shouldDeselectItemAtItem:(NSInteger)item;

- (CGSize)sizeForItemAtItem:(NSInteger)item;

- (void)willDisplayCell:(UICollectionViewCell *)cell forItem:(NSInteger)item;

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItem:(NSInteger)item;

#pragma mark - public method
// 更新数据
- (void)updateObject:(id)obj;

@end

NS_ASSUME_NONNULL_END
