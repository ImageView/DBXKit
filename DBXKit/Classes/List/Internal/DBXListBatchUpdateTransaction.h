//
//  DBXListBatchUpdateTransaction.h
//  DBXKit
//
//  Created by 调包侠 on 2025/10/11.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXListUpdateTransactable.h"

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

- (void)addCompletionBlock:(DBXListUpdateCompletion)completion;

@end

NS_ASSUME_NONNULL_END
