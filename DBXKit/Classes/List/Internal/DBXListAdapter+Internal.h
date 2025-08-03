//
//  DBXListSectionController.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListAdapterExtension.h"
#import "DBXListDiffable.h"

@interface DBXListAdapter (Internal)

- (void)_performDataSourceChange:(void (^)(void))block;

- (void)tryRegisterCell:(Class)cellClass withIdentifier:(NSString *)identifier;

- (void)tryRegisterSupplementaryView:(Class)supplementaryViewClass elementKind:(NSString *)elementKind withIdentifier:(NSString *)identifier;

- (NSArray *)objectWithDeduplication:(NSArray <id<DBXListDiffable>> *)objects;

@end
