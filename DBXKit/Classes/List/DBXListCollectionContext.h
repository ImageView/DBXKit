//
//  DBXListCollectionContext.h
//  DBXKit
//
//  Created by 调包侠 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListCollectionContext_h
#define DBXListCollectionContext_h

#import <UIKit/UIKit.h>

@class DBXListSectionController;
@protocol DBXListCollectionContext <NSObject>

/**
 container即所在的collectionView
*/
//container的bounds.size
@property(nonatomic, assign, readonly) CGSize containerSize;
@property(nonatomic, assign, readonly) UIEdgeInsets containerInset;
@property(nonatomic, assign, readonly) CGPoint containerContentOffset;

// 对应sectionController的section的size
- (CGSize)containerSizeForSectionController:(DBXListSectionController *)sectionController;
- (NSInteger)itemForCell:(UICollectionViewCell *)cell sectionController:(DBXListSectionController *)sectionController;
- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item sectionController:(DBXListSectionController *)sectionController;

// 获取循环中的cell
- (UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass forSectionController:(DBXListSectionController *)sectionController atItem:(NSInteger)item;

// 获取循环中的补充视图
- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(DBXListSectionController *)sectionController
                                                                    viewClass:(Class)viewClass;
@end

#endif /* DBXListCollectionContext_h */
