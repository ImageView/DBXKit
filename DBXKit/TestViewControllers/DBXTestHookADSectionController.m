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
    NSLog(@"- (void)didSelectItemAtItem:(NSInteger)item;");
}

@end

@implementation DBXTestHookADNumberSectionController

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    UICollectionViewCell *cell = [self dequeueReusableCellOfClass:[UICollectionViewCell class] atItem:item];
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

- (void)didSelectItemAtItem:(NSInteger)item {
    NSLog(@"- (void)didSelectItemAtItem:(NSInteger)item;");
}

@end
