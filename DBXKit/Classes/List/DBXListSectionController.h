//
//  DBXListSectionController.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBXListCollectionContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXListSectionController : NSObject

/** 上下文
 sectionController不持有collectionView实例本身，避免循环引用，因此这里用代理的方式把需要涉及collectionView实例的内容移交回adapter（adapter中有collectionView实例）去处理
*/
@property(nonatomic, weak) id <DBXListCollectionContext> context;

// 本section的item数
- (NSInteger)numberOfItems;

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item;

// 获取循环池中的cell
- (UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass atItem:(NSInteger)item;

@end

NS_ASSUME_NONNULL_END
