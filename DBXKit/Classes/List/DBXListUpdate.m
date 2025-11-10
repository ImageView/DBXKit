//
//  DBXListUpdate.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/17.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListUpdate.h"
#import "DBXListBatchUpdateTransaction.h"
#import "DBXListUpdateTransactionBuilder.h"

@interface DBXListUpdate ()
// 是否有更新操作在执行
@property(nonatomic, assign) BOOL hasQueuedUpdate;
// 当前更新操作
@property(nonatomic, strong) DBXListBatchUpdateTransaction *transaction;
// 操作管理
@property(nonatomic, strong) DBXListUpdateTransactionBuilder *transactionBuilder;

@end

@implementation DBXListUpdate

- (instancetype)init
{
    self = [super init];
    if (self) {
        _updateConfig = (DBXListUpdateConfig){
            .enable = YES,
            .minInterval = 50,
            .maxInterval = 500
        };
        _transactionBuilder = [[DBXListUpdateTransactionBuilder alloc] init];
    }
    return self;
}

- (void)performUpdateWithCollectionViewBlock:(DBXListUpdateCollectionViewBlock)collectionViewBlock
                                    animated:(BOOL)animated
                         transitionDataBlock:(DBXListUpdateTransitionDataBlock)transitionDataBlock
                              applyDataBlock:(DBXListUpdateApplyTransitionDataBlock)applyBlock
                                  completion:(DBXListUpdateCompletion)completion {
    [self.transactionBuilder addSectionBatchUpdateAnimated:animated
                                       collectionViewBlock:collectionViewBlock
                                       transitionDataBlock:transitionDataBlock
                                     applySectionDataBlock:applyBlock
                                                completion:completion];
    [self updateIfNeed];
}

- (void)updateIfNeed {
    if (self.hasQueuedUpdate) {
        return;
    }
    self.hasQueuedUpdate = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self update];
    });
}

- (void)update {
    self.hasQueuedUpdate = NO;
    if (self.transaction) {
        return;
    }
    self.transaction = [self.transactionBuilder buildTransaction];
    [self.transaction begin];
}

@end
