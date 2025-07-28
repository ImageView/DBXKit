//
//  DBXListSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListAdapter+UICollectionView.h"
#import "DBXListSectionController.h"
#import "DBXListAdapterExtension.h"

@implementation DBXListAdapter (UICollectionView)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionMap.objects.count;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:section];
    return [sectionController numberOfItems];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    UICollectionViewCell *cell = [sectionController cellForItemAtItem:indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionViewDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.collectionViewDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    
}
@end
