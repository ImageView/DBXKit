//
//  DBXListBatchUpdateTransaction.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/10/11.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXListUpdateTransactable.h"
#import "DBXListUpdatingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXListBatchUpdateTransaction : NSObject<DBXListUpdateTransactable>

- (instancetype)initWithCollectionViewBlock:(DBXListUpdateCollectionViewBlock)collectionViewBlock
                                   animated:(BOOL)animated
                        transitionDataBlock:(DBXListUpdateTransitionDataBlock)transitionDataBlock
                      applySectionDataBlock:(DBXListUpdateApplyTransitionDataBlock)applySectionDataBlock
                           completionBlocks:(NSArray<DBXListUpdateCompletion> *)completionBlocks;

- (void)begin;
- (BOOL)cancel;

- (DBXListBatchUpdateState)state;

@end

NS_ASSUME_NONNULL_END
