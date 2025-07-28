//
//  DBXTestHookADSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXTestHookADSectionController.h"
#import <QMUIKit/QMUIKit.h>

@implementation DBXTestHookADSectionController

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    UICollectionViewCell *cell = [self dequeueReusableCellOfClass:[UICollectionViewCell class] atItem:item];
    
    cell.backgroundColor = [UIColor redColor];
    return cell;
}

- (void)didSelectItemAtItem:(NSInteger)item {
    NSLog(@"%s section:%d", __func__, (int)self.section);
}

- (CGSize)sizeForItemAtItem:(NSInteger)item {
    return CGSizeMake(100, 200);
}

@end

@implementation DBXTestHookADNumberSectionController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 5;
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 3;
}

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    UICollectionViewCell *cell = [self dequeueReusableCellOfClass:[UICollectionViewCell class] atItem:item];
    
    cell.backgroundColor = [UIColor qmui_randomColor];
    return cell;
}

- (CGSize)sizeForItemAtItem:(NSInteger)item {
    return CGSizeMake(30 * (item + 1), 200);
}

- (void)didSelectItemAtItem:(NSInteger)item {
    NSLog(@"%s section:%d", __func__, (int)self.section);
}

- (void)willDisplayCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    NSLog(@"%s section:%d", __func__, (int)self.section);
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    NSLog(@"%s section:%d", __func__, (int)self.section);
}


@end
