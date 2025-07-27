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
    }
    return self;
}

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
        [self _performDataSourceChange:^{
            self->_collectionView.dataSource = nil;
            self->_collectionView.dataSource = self;
            [self _updateObjects];
        }];
    }
}

#pragma mark - Private method
- (void)_updateObjects {
    if (!_collectionView || !_dataSource) {
        return;
    }
    DBXListSectionMap *map = self.sectionMap;
    NSArray *objects = [self.dataSource objectsForListAdapter:self];
    NSMutableArray *sectionControllers = [NSMutableArray array];
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DBXListSectionController *sectionController = [map sectionControllerForObject:obj];
        if (![sectionController isKindOfClass:[DBXListSectionController class]]) {
            sectionController = [self.dataSource listAdapter:self sectionControllerForObject:obj];
        }
        NSAssert([sectionController isKindOfClass:[DBXListSectionController class]], @"sectionController at index %d should be kind of DBXListSectionController", (int)idx);
        sectionController.context = self;
        [sectionControllers addObject:sectionController];
    }];
    [map updateObjects:objects sectionControllers:sectionControllers.copy];
    [self reloadData];
}

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (UICollectionViewCell *)_dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath sectionController:(DBXListSectionController *)sectionController {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}
#pragma mark - Private method -- End

#pragma mark - <DBXListCollectionContext>
- (UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass forSectionController:(DBXListSectionController *)sectionController atItem:(NSInteger)item {
    NSString *identifier = DBXListReusableCellIdentifier(cellClass, nil);
    [self tryRegisterCell:cellClass withIdentifier:identifier];
    
    NSInteger section = [self.sectionMap sectionForSectionController:sectionController];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    return [self _dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath sectionController:sectionController];
}


@end
