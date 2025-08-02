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

- (void)updateObject:(id)obj {
    self.object = obj;
}

#pragma mark - for UICollectionViewDataSource
- (NSInteger)numberOfItems {
    return 1;
}

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    return [self.collectionViewContext dequeueReusableCellOfClass:[UICollectionViewCell class] forSectionController:self atItem:item];
}

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)kind {
    return [self.collectionViewContext dequeueReusableSupplementaryViewOfKind:kind forSectionController:self viewClass:[UICollectionReusableView class]];
}

#pragma mark - for UICollectionViewDelegate
- (void)didSelectItemAtItem:(NSInteger)item {
    
}

- (void)didDeselectItemAtItem:(NSInteger)item {
    
}

- (void)didHighlightItemAtItem:(NSInteger)item {
    
}

- (void)didUnhighlightItemAtItem:(NSInteger)item {
    
}

- (BOOL)shouldSelectItemAtItem:(NSInteger)item {
    return YES;
}

- (BOOL)shouldDeselectItemAtItem:(NSInteger)item {
    return YES;
}

- (CGSize)sizeForItemAtItem:(NSInteger)item {
    return CGSizeMake(50, 50);
}

- (void)willDisplayCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    
}

@end
