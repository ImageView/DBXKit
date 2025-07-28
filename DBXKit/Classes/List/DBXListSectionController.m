//
//  DBXListSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListSectionController.h"
#import "DBXCore.h"

@implementation DBXListSectionController

#pragma mark - for UICollectionViewDataSource
- (NSInteger)numberOfItems {
    return 1;
}

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    return [self dequeueReusableCellOfClass:[UICollectionViewCell class] atItem:item];
}

- (UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass atItem:(NSInteger)item {
//    DBXpLog(@"index = %d", (int)item);
    return [self.context dequeueReusableCellOfClass:cellClass forSectionController:self atItem:item];
}

#pragma mark - for UICollectionViewDelegate
- (void)didSelectItemAtItem:(NSInteger)item {
    
}

- (void)didDeselectItemAtItem:(NSInteger)item {
    
}

- (CGSize)sizeForItemAtItem:(NSInteger)item {
//    return CGSizeZero;
    return CGSizeMake(50, 50);
}

- (UIEdgeInsets)inset {
    return UIEdgeInsetsZero;
}

- (void)willDisplayCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    
}

@end
