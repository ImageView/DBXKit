//
//  DBXListSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListAdapter+Internal.h"
#import "dbxCore.h"

@implementation DBXListAdapter (Internal)


- (void)_performDataSourceChange:(void (^)(void))block {
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void)tryRegisterCell:(Class)cellClass withIdentifier:(NSString *)identifier {
    if (![identifier isKindOfClass:[NSString class]] || [self.registerCellIdentiferSet containsObject:identifier]) {
        return;
    }
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    [self.registerCellIdentiferSet addObject:identifier];
}

- (void)tryRegisterSupplementaryView:(Class)supplementaryViewClass elementKind:(NSString *)elementKind withIdentifier:(NSString *)identifier {
    if (![identifier isKindOfClass:[NSString class]] || [self.registerSupplementaryViewIdentiferSet containsObject:identifier]) {
        return;
    }
    [self.collectionView registerClass:supplementaryViewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
    [self.registerSupplementaryViewIdentiferSet addObject:identifier];
}

// 去重
- (NSArray *)objectWithDeduplication:(NSArray <id<DBXListDiffable>> *)objects {
    if (![objects isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray *uniqueObjects = [NSMutableArray array];
    NSMapTable *map = [NSMapTable strongToStrongObjectsMapTable];
    for (id <DBXListDiffable> obj in objects) {
        NSString *identifi = obj.diffIdentifier;
        if (identifi && ![map objectForKey:identifi]) {
            [uniqueObjects addObject:obj];
            [map setObject:obj forKey:identifi];
        } else {
            DBXpLog(@"%@的identifi：%@重复了，只保留第一个", obj, identifi);
        }
    }
    return uniqueObjects;
}

@end
