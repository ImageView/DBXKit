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

@end
