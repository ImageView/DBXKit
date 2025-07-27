//
//  DBXListSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListAdapter+UICollectionView.h"
#import "DBXListAdapterExtension.h"

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

@end
