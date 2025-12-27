//
//  DBXListCollectionDelegateProxy.h
//  DBXKit
//
//  Created by 调包侠 on 2025/7/28.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXListAdapter;
@interface DBXListCollectionDelegateProxy : NSProxy

- (instancetype)initWithCollectionViewTarget:(nullable id<UICollectionViewDelegate>)collectionViewTarget scrollViewTarget:(nullable id<UIScrollViewDelegate>)scrollViewTarget listAdapter:(DBXListAdapter *)adapter;

@end

NS_ASSUME_NONNULL_END
