//
//  DBXListSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListSectionControllerExtension.h"
#import "DBXCore.h"

@implementation DBXListSectionController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _inset = UIEdgeInsetsZero;
        _minimumLineSpacing = 0.0;
        _minimumInteritemSpacing = 0.0;
        _section = NSNotFound;
    }
    return self;
}

#pragma mark - for UICollectionViewDataSource
- (NSInteger)numberOfItems {
    return 1;
}

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    return [self dequeueReusableCellOfClass:[UICollectionViewCell class] atItem:item];
}

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)kind atItem:(NSInteger)item {
    return [self dequeueReusableSupplementaryViewOfClass:[UICollectionReusableView class] elementKind:kind atItem:item];
}

#pragma mark - for UICollectionViewDelegate
- (void)didSelectItemAtItem:(NSInteger)item {
    
}

- (void)didDeselectItemAtItem:(NSInteger)item {
    
}

- (CGSize)sizeForItemAtItem:(NSInteger)item {
    return CGSizeMake(50, 50);
}

- (void)willDisplayCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    
}

#pragma mark - public method
- (UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass atItem:(NSInteger)item {
//    DBXpLog(@"index = %d", (int)item);
    return [self.context dequeueReusableCellOfClass:cellClass forSectionController:self atItem:item];
}

- (UICollectionReusableView *)dequeueReusableSupplementaryViewOfClass:(Class)viewClass elementKind:(NSString *)elementKind atItem:(NSInteger)item {
    return [self.context dequeueReusableSupplementaryViewOfKind:elementKind forSectionController:self viewClass:viewClass atItem:item];
}
@end
