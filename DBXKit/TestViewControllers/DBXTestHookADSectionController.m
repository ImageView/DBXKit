//
//  DBXTestHookADSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXTestHookADSectionController.h"
#import <QMUIKit/QMUIKit.h>
#import "DBXTestHookADCollectionCell.h"

@implementation DBXTestHookADSectionController

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    DBXTestHookADCollectionCell *cell = (DBXTestHookADCollectionCell *)[self.collectionViewContext dequeueReusableCellOfClass:[DBXTestHookADCollectionCell class] forSectionController:self atItem:item];
    cell.textLabel.text = self.object;

    cell.backgroundColor = [UIColor qmui_randomColor];
    return cell;
}

- (void)didSelectItemAtItem:(NSInteger)item {
    NSLog(@"%s section:%d", __func__, (int)self.section);
    NSString *obj = self.object;
    if ([obj containsString:@"插入"]) {
        [self.delegate insertObjectToItem:-1];
    } else if ([obj containsString:@"删除"]) {
        [self.delegate deleteObjectItem:-1];
    } else if ([obj containsString:@"修改"]) {
        [self.delegate updateObject:[NSString stringWithFormat:@"更新后%ld", random()%100000] atItem:-1];
    } else {
        [self.delegate sectionColtrollerReload];
    }
}

- (CGSize)sizeForItemAtItem:(NSInteger)item {
    return CGSizeMake(self.collectionViewContext.containerSize.width /2, 100);//CGSizeMake(150, 100);
}

@end

@implementation DBXTestADSectionController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 5;
        self.minimumInteritemSpacing = 10;
        self.supplementaryViewSource = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    NSLog(@"%s object:%@,section:%d item:%d", __func__, self.object, (int)self.section, (int)item);
    DBXTestADCollectionCell *cell = (DBXTestADCollectionCell *)[self.collectionViewContext dequeueReusableCellOfClass:[DBXTestADCollectionCell class] forSectionController:self atItem:item];
    cell.textLabel.text = self.object;
    cell.backgroundColor = [UIColor qmui_randomColor];
    return cell;
}

- (CGSize)sizeForItemAtItem:(NSInteger)item {
    return CGSizeMake(300, 100);
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

#pragma mark - <DBXListSupplementaryViewSource>
- (CGSize)supplementaryViewReferenceSizeOfKind:(NSString *)elementKind {
    if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        return CGSizeMake(100, 20);
    }
    return CGSizeMake(100, 50);
}

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)kind {
    UICollectionReusableView *view = [self.collectionViewContext dequeueReusableSupplementaryViewOfKind:kind forSectionController:self viewClass:[UICollectionReusableView class]];
    view.backgroundColor = [UIColor qmui_randomColor];
    return view;
}

@end
