//
//  DBXListBatchUpdateTransaction.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/10/11.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListBatchUpdateTransaction.h"
#import "DBXListUpdatingDelegate.h"

@interface DBXListBatchUpdateTransaction ()
@property(nonatomic, copy) DBXListUpdateCollectionViewBlock collectionViewBlock;
@property(nonatomic, copy) DBXListUpdateTransitionDataBlock transitionDataBlock;
@property(nonatomic, copy) DBXListUpdateApplyTransitionDataBlock applyBlock;
@end

@implementation DBXListBatchUpdateTransaction

- (instancetype)initWithCollectionViewBlock:(DBXListUpdateCollectionViewBlock)collectionViewBlock
                                   animated:(BOOL)animated
                           sectionDataBlock:(DBXListUpdateTransitionDataBlock)sectionDataBlock
                      applySectionDataBlock:(DBXListUpdateApplyTransitionDataBlock)applySectionDataBlock
                           completionBlocks:(NSArray<DBXListUpdateCompletion> *)completionBlocks {
    if (self = [super init]) {
//        _collectionView = collectionViewBlock ? collectionViewBlock() : nil;
//        _animated = animated;
//        _sectionData = sectionDataBlock ? sectionDataBlock() : nil;
//        _applySectionDataBlock = [applySectionDataBlock copy];
//        _completionBlocks = [completionBlocks copy];
    }
    return self;
}

- (void)begin {
    
}

- (BOOL)cancel {
    return YES;
}

- (void)_executeCompletionAsFinished:(BOOL)finish {
    
}

@end
