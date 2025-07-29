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

#pragma mark - <UICollectionViewDataSource>
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

#pragma mark - <UICollectionViewDelegate>
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionViewDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.collectionViewDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    [sectionController didSelectItemAtItem:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionViewDelegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)]) {
        [self.collectionViewDelegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    [sectionController didDeselectItemAtItem:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionViewDelegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [self.collectionViewDelegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    [sectionController willDisplayCell:cell forItem:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionViewDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [self.collectionViewDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    [sectionController didEndDisplayingCell:cell forItem:indexPath.item];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
    return [sectionController sizeForItemAtItem:indexPath.item];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:section];
    return sectionController.inset;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:section];
    return sectionController.minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:section];
    return sectionController.minimumInteritemSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:section];
    if (!sectionController.supplementaryViewSource) {
        return CGSizeZero;
    }
    return [sectionController.supplementaryViewSource supplementaryViewReferenceSizeOfKind:UICollectionElementKindSectionHeader];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:section];
    if (!sectionController.supplementaryViewSource) {
        return CGSizeZero;
    }
    return [sectionController.supplementaryViewSource supplementaryViewReferenceSizeOfKind:UICollectionElementKindSectionFooter];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DBXListSectionController *sectionController = [self.sectionMap sectionControllerForSection:section];
    return [sectionController viewForSupplementaryElementOfClass:<#(nonnull Class)#> elementKind:<#(nonnull NSString *)#> atItem:<#(NSInteger)#>]
}

@end
