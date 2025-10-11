//
//  DBXListAdapter.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListAdapter.h"
#import "DBXListAdapterExtension.h"
#import "DBXListSectionControllerExtension.h"

@implementation DBXListAdapter

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _viewController = viewController;
        _sectionMap = [[DBXListSectionMap alloc] init];
        _update = [[DBXListUpdate alloc] init];
    }
    return self;
}

- (void)reloadData {
    [self _updateObjects];
}

- (void)performUpdatesAnimated:(BOOL)animated completion:(void (^)(BOOL finish))completion {
    if (!_collectionView || !_dataSource) {
        return;
    }
    id<DBXListAdapterDataSource> dataSource = self.dataSource;

    __weak __typeof(self)weakSelf = self;
    // 获取collectionView视图
    DBXListUpdateCollectionViewBlock collectionViewBlock = ^UICollectionView *{
        return weakSelf.collectionView;
    };
    
    // 获取数据（从代理中获取））
    DBXListUpdateTransitionDataBlock transitionBlock = ^DBXListTransitionData *{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        DBXListTransitionData *data = nil;
        if (strongSelf) {
            NSArray *objects = [strongSelf objectWithDeduplication:[dataSource objectsForListAdapter:strongSelf]];
            data = [strongSelf _transitionDataWithObjects:objects dataSource:dataSource];
        }
        return data;
    };
    
    // 应用数据
    DBXListUpdateApplyTransitionDataBlock applyBlock = ^void(DBXListTransitionData *data) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf _updateWithTransitionData:data];
        }
    };
    
    // 完成
    DBXListUpdateCompletion completionBlock = ^void(BOOL finish) {
        if (completion) {
            completion(finish);
        }
    };
    
    [self.update performUpdateWithCollectionViewBlock:collectionViewBlock transitionDataBlock:transitionBlock applyDataBlock:applyBlock completion:completionBlock];
}

#pragma mark - Setter
- (void)setDataSource:(id<DBXListAdapterDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    [self _performDataSourceChange:^{
        self->_dataSource = dataSource;
        self->_collectionView.dataSource = nil;
        self->_collectionView.dataSource = self;
        [self _updateObjects];
    }];
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    if (_collectionView != collectionView || _collectionView.dataSource != self) {
        _collectionView = collectionView;
        _registerCellIdentiferSet = [[NSMutableSet alloc] init];
        _registerSupplementaryViewIdentiferSet = [[NSMutableSet alloc] init];
        [self _performDataSourceChange:^{
            self->_collectionView.dataSource = nil;
            self->_collectionView.dataSource = self;
            
            [self _updateCollectionViewDelegate];
            [self _updateObjects];
        }];
    }
}

- (void)setCollectionViewDelegate:(id<UICollectionViewDelegate>)collectionViewDelegate {
    if (_collectionViewDelegate != collectionViewDelegate) {
        _collectionViewDelegate = collectionViewDelegate;
        [self _createProxyDelegate];
    }
}

- (void)setScrollViewDelegate:(id<UIScrollViewDelegate>)scrollViewDelegate {
    if (_scrollViewDelegate != scrollViewDelegate) {
        _scrollViewDelegate = scrollViewDelegate;
        [self _createProxyDelegate];
    }
}

#pragma mark - Private method
- (void)_updateObjects {
    if (!_collectionView || !_dataSource) {
        return;
    }
    NSArray *objects = [self objectWithDeduplication:[self.dataSource objectsForListAdapter:self]];
    [self _updateWithTransitionData:[self _transitionDataWithObjects:objects dataSource:self.dataSource]];
}

// 生成过渡数据
- (DBXListTransitionData *)_transitionDataWithObjects:(NSArray *)objects dataSource:(id<DBXListAdapterDataSource>)dataSource {
    DBXListSectionMap *map = self.sectionMap;
    if (!dataSource) {
        return [[DBXListTransitionData alloc] initWithFromObjects:map.objects
                                                        toObjects:@[]
                                               sectionControllers:@[]];
    }
    
    NSMutableArray *sectionControllers = [NSMutableArray array];
    NSMutableArray *tempObjects = [NSMutableArray array];
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DBXListSectionController *sectionController = [map sectionControllerForObject:obj];
        if (![sectionController isKindOfClass:[DBXListSectionController class]]) {
            sectionController = [self.dataSource listAdapter:self sectionControllerForObject:obj];
            sectionController.section = idx;
            [sectionController updateObject:obj];
            sectionController.collectionViewContext = self;
            sectionController.viewController = self.viewController;
        }
        if (![sectionController isKindOfClass:[DBXListSectionController class]]) {
            NSAssert(NO, @"sectionController at index %d should be kind of DBXListSectionController", (int)idx);
            return;
        }
        [sectionControllers addObject:sectionController];
        [tempObjects addObject:obj];
    }];
    return [[DBXListTransitionData alloc] initWithFromObjects:map.objects toObjects:tempObjects sectionControllers:sectionControllers];
}

- (void)_updateWithTransitionData:(DBXListTransitionData *)transitionData {
    if (!_collectionView || !_dataSource) {
        return;
    }
    [self.sectionMap updateObjects:transitionData.toObjects sectionControllers:transitionData.sectionContollers];
    [self.collectionView reloadData];
}

- (UICollectionViewCell *)_dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath sectionController:(DBXListSectionController *)sectionController {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UICollectionReusableView *)_dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                           withReuseIdentifier:(NSString *)identifier
                                                                  forIndexPath:(NSIndexPath *)indexPath
                                                          forSectionController:(DBXListSectionController *)sectionController {
    UICollectionReusableView * view = [self.collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier forIndexPath:indexPath];
    return view;
}

- (void)_createProxyDelegate {
    _collectionView.delegate = nil;
    self.delegateProxy = [[DBXListCollectionDelegateProxy alloc] initWithCollectionViewTarget:_collectionViewDelegate scrollViewTarget:_scrollViewDelegate listAdapter:self];
    [self _updateCollectionViewDelegate];
}

- (void)_updateCollectionViewDelegate {
    self.collectionView.delegate = (id<UICollectionViewDelegate>)self.delegateProxy ? : self;
}

#pragma mark - <DBXListCollectionContext>
- (CGSize)containerSize {
    return self.collectionView.bounds.size;
}

- (UIEdgeInsets)containerInset {
    return self.collectionView.contentInset;
}

- (CGPoint)containerContentOffset {
    return self.collectionView.contentOffset;
}

- (CGSize)containerSizeForSectionController:(DBXListSectionController *)sectionController {
    UIEdgeInsets inset = sectionController.inset;
    return CGSizeMake(self.containerSize.width - inset.left - inset.right, self.containerSize.height - inset.top - inset.bottom);
}

- (NSInteger)itemForCell:(UICollectionViewCell *)cell sectionController:(DBXListSectionController *)sectionController {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    return indexPath ? indexPath.item : NSNotFound;
}

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item sectionController:(DBXListSectionController *)sectionController {
    NSInteger section = [self.sectionMap sectionForSectionController:sectionController];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

- (UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass forSectionController:(DBXListSectionController *)sectionController atItem:(NSInteger)item {
    NSString *identifier = DBXListReusableCellIdentifier(cellClass, nil);
    [self tryRegisterCell:cellClass withIdentifier:identifier];
    
    NSInteger section = [self.sectionMap sectionForSectionController:sectionController];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    return [self _dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath sectionController:sectionController];
}

- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(DBXListSectionController *)sectionController
                                                                    viewClass:(Class)viewClass {
    NSString *identifier = DBXListReusableViewIdentifier(viewClass, elementKind, nil);
    [self tryRegisterSupplementaryView:viewClass elementKind:elementKind withIdentifier:identifier];
    
    NSInteger section = [self.sectionMap sectionForSectionController:sectionController];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return [self _dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier forIndexPath:indexPath forSectionController:sectionController];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

@end
