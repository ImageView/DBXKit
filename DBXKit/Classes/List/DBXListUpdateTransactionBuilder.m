//
//  DBXListUpdateTransactionBuilder.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/11/10.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListUpdateTransactionBuilder.h"
#import "DBXListUpdateTransactable.h"
#import "DBXListBatchUpdateTransaction.h"

@interface DBXListUpdateTransactionBuilder ()

@property(nonatomic, copy) DBXListUpdateCollectionViewBlock collectionViewBlock;
@property(nonatomic, copy) DBXListUpdateTransitionDataBlock transitionDataBlock;
@property(nonatomic, copy) DBXListUpdateApplyTransitionDataBlock applyBlock;
@property(nonatomic, strong) NSMutableArray<DBXListUpdateCompletion> *completionBlocks;
@property(nonatomic, assign) BOOL animated;

@end

@implementation DBXListUpdateTransactionBuilder

- (void)addSectionBatchUpdateAnimated:(BOOL)animated
                  collectionViewBlock:(DBXListUpdateCollectionViewBlock)collectionViewBlock
                  transitionDataBlock:(DBXListUpdateTransitionDataBlock)transitionDataBlock
                applySectionDataBlock:(DBXListUpdateApplyTransitionDataBlock)applySectionDataBlock
                           completion:(nullable DBXListUpdateCompletion)completion {
    self.animated = animated;
    self.collectionViewBlock = collectionViewBlock;
    self.transitionDataBlock = transitionDataBlock;
    self.applyBlock = applySectionDataBlock;
    if (completion) {
        [self.completionBlocks addObject:completion];
    }
}

- (id<DBXListUpdateTransactable>)buildTransaction {
    DBXListBatchUpdateTransaction *transaction = [[DBXListBatchUpdateTransaction alloc] initWithCollectionViewBlock:self.collectionViewBlock animated:self.animated transitionDataBlock:self.transitionDataBlock applySectionDataBlock:self.applyBlock completionBlocks:self.completionBlocks];
    
    return transaction;
}

@end
