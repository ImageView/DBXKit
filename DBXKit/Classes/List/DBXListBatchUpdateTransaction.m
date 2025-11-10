//
//  DBXListBatchUpdateTransaction.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/10/11.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListBatchUpdateTransaction.h"

@interface DBXListBatchUpdateTransaction ()
@property (nonatomic, copy) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL animated;
@property(nonatomic, copy) DBXListTransitionData *transitionData;
@property(nonatomic, copy) DBXListUpdateApplyTransitionDataBlock applyBlock;
@property (nonatomic, copy) NSArray<DBXListUpdateCompletion> *completionBlocks;
@property (nonatomic, copy) NSArray<DBXListUpdateCompletion> *inUpdateCompletionBlocks;

@end

@implementation DBXListBatchUpdateTransaction

- (instancetype)initWithCollectionViewBlock:(DBXListUpdateCollectionViewBlock)collectionViewBlock
                                   animated:(BOOL)animated
                        transitionDataBlock:(DBXListUpdateTransitionDataBlock)transitionDataBlock
                      applySectionDataBlock:(DBXListUpdateApplyTransitionDataBlock)applySectionDataBlock
                           completionBlocks:(NSArray<DBXListUpdateCompletion> *)completionBlocks {
    if (self = [super init]) {
        _collectionView = collectionViewBlock ? collectionViewBlock() : nil;
        _animated = animated;
        _transitionData = transitionDataBlock ? transitionDataBlock() : nil;
        _applyBlock = [applySectionDataBlock copy];
        _completionBlocks = [completionBlocks copy];
    }
    return self;
}

- (void)begin {
    
}

- (BOOL)cancel {
    return YES;
}

- (void)_executeCompletionAsFinished:(BOOL)finish {
    for (DBXListUpdateCompletion block in self.completionBlocks) {
        block(finish);
    }
    
    NSArray *inUpdateCompletionBlocks = [_inUpdateCompletionBlocks copy];
    for (DBXListUpdateCompletion block in inUpdateCompletionBlocks) {
        block(finish);
    }
//    self.state = IGListBatchUpdateStateIdle;
}

@end
