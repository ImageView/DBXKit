//
//  DBXListAdapterExtension.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListAdapterExtension_h
#define DBXListAdapterExtension_h

#import "DBXListAdapter.h"
#import "DBXListSectionMap.h"
#import "DBXListAdapter+UICollectionView.h"
#import "DBXListAdapter+Internal.h"
#import "DBXListCollectionContext.h"
#import "DBXListCollectionDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN
NS_INLINE NSString *DBXListReusableViewIdentifier(Class viewClass, NSString * _Nullable elementKind, NSString * _Nullable customIdentifier) {
    return [NSString stringWithFormat:@"%@%@%@", elementKind ?: @"", customIdentifier ?: @"", NSStringFromClass(viewClass)];
}

NS_INLINE NSString *DBXListReusableCellIdentifier(Class cellClass, NSString * _Nullable customIdentifier) {
    return DBXListReusableViewIdentifier(cellClass, @"Cell", customIdentifier);
}


@interface DBXListAdapter ()<DBXListCollectionContext>

// 存储section、sectionController的信息
@property(nonatomic, strong) DBXListSectionMap *sectionMap;
// 注册的cell循环信息
@property(nonatomic, strong) NSMutableSet <NSString *> *registerCellIdentiferSet;
// 转发delegate
@property(nonatomic, strong) DBXListCollectionDelegateProxy *delegateProxy;
@end

NS_ASSUME_NONNULL_END

#endif /* DBXListAdapterExtension_h */
