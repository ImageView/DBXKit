//
//  DBXListBatchUpdateTransaction.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/10/11.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListBatchUpdateTransaction.h"
#import "DBXListDiff.h"
#import "DBXListBatchUpdateData.h"

typedef NS_ENUM (NSInteger, DBXListBatchUpdateTransactionMode) {
    DBXListBatchUpdateTransactionModeCancellable,
    DBXListBatchUpdateTransactionModeNotCancellable,
    DBXListBatchUpdateTransactionModeCancelled,
};

@interface DBXListBatchUpdateTransaction ()
@property (nonatomic, copy) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL animated;
@property(nonatomic, copy) DBXListTransitionData *transitionData;
@property(nonatomic, copy) DBXListUpdateApplyTransitionDataBlock applyBlock;
@property (nonatomic, copy) NSArray<DBXListUpdateCompletion> *completionBlocks;
@property (nonatomic, copy) NSMutableArray<DBXListUpdateCompletion> *inUpdateCompletionBlocks;
@property (nonatomic, assign) DBXListBatchUpdateState state;
@property (nonatomic, assign) DBXListBatchUpdateTransactionMode mode;
@property (nonatomic, strong) DBXListBatchUpdateData *actualCollectionViewUpdates;

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
    if (self.collectionView == nil) {
        [self _bail];
        return;
    }
    self.state = DBXListBatchUpdateStateQueuedBatchUpdate;

    [self _diff];
}

- (BOOL)cancel {
    return YES;
}

- (void)_diff {
    DBXListTransitionData *data = self.transitionData;
    __weak __typeof__(self) weakSelf = self;
    
    DBXListDiffIndexResult *set = [DBXListDiff listDiffingWithOldArray:data.fromObjects newArray:data.toObjects option:DBXListDiffOptionListDiffEquality];
    [self _didDiff:set];
}

- (void)_didDiff:(DBXListDiffIndexResult *)diffResult {
    if (self.mode == DBXListBatchUpdateTransactionModeCancelled) {
        return;
    }

    self.mode = DBXListBatchUpdateTransactionModeNotCancellable;

    @try {
        id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;

        if (collectionViewDataSource == nil) {
            [self _bail];
        } else if (diffResult.changeCount > 100) {
            [self _reload];
        } else if (self.transitionData && [self.collectionView numberOfSections] != (NSInteger)self.transitionData.fromObjects.count) {
            [self _reload];
        } else {
            [self _applyDiff:diffResult];
        }
    } @catch (NSException *exception) {
        
        @throw exception;
    }
}

- (void)_applyDiff:(DBXListDiffIndexResult *)diffResult {
    void (^updates)(void) = ^ {
        [self _applyDataUpdates];
        [self _applyCollectioViewUpdates:diffResult];
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        [self _executeCompletionAsFinished:finished];
    };

    @try {
        if (self.animated) {
            [self.collectionView performBatchUpdates:updates completion:completion];
        } else {
            [UIView performWithoutAnimation:^{
                [self.collectionView performBatchUpdates:updates completion:completion];
            }];
        }
    } @catch (NSException *exception) {
        if ([[exception name] isEqualToString:NSInternalInconsistencyException]) {
            [self begin];
        }
    }
}

- (void)_applyCollectioViewUpdates:(DBXListDiffIndexResult *)diffResult {
    [self.collectionView deleteSections:diffResult.deletes];
    [self.collectionView insertSections:diffResult.inserts];
    for (DBXListMoveIndex *move in diffResult.moves) {
        [self.collectionView moveSection:move.from toSection:move.to];
    }
}

- (void)_bail {
    [self _executeCompletionAsFinished:NO];
}

- (void)_reload {
    [self _applyDataUpdates];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    [self _executeCompletionAsFinished:YES];
}

- (void)_applyDataUpdates {
    self.state = DBXListBatchUpdateStateExecutingBatchUpdateBlock;
    
    if (self.applyBlock != nil && self.transitionData != nil) {
        self.applyBlock((DBXListTransitionData *)self.transitionData);
    }

    self.state = DBXListBatchUpdateStateExecutedBatchUpdateBlock;
}

- (void)_executeCompletionAsFinished:(BOOL)finish {
    for (DBXListUpdateCompletion block in self.completionBlocks) {
        block(finish);
    }
    
    NSArray *inUpdateCompletionBlocks = [_inUpdateCompletionBlocks copy];
    for (DBXListUpdateCompletion block in inUpdateCompletionBlocks) {
        block(finish);
    }
    self.state = DBXListBatchUpdateStateIdle;
}

- (void)addCompletionBlock:(DBXListUpdateCompletion)completion {
    if (!_inUpdateCompletionBlocks) {
        _inUpdateCompletionBlocks = [NSMutableArray new];
    }
    [_inUpdateCompletionBlocks addObject:completion];
}
@end
