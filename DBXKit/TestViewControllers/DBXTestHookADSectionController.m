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
    NSLog(@"%s", __func__);
}

@end

@implementation DBXTestHookADNumberSectionController

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    UICollectionViewCell *cell = [self dequeueReusableCellOfClass:[UICollectionViewCell class] atItem:item];
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

- (void)didSelectItemAtItem:(NSInteger)item {
    NSLog(@"%s", __func__);
}

- (void)willDisplayCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    NSLog(@"%s", __func__);
}

- (void)didEndDisplayingCell:(UICollectionViewCell *)cell forItem:(NSInteger)item {
    NSLog(@"%s", __func__);
}


@end
