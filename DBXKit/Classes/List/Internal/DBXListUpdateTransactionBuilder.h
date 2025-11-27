//
//  DBXListUpdateTransactionBuilder.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/11/10.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXListUpdatingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DBXListUpdateTransactable;
@interface DBXListUpdateTransactionBuilder : NSObject

- (void)addSectionBatchUpdateAnimated:(BOOL)animated
                  collectionViewBlock:(DBXListUpdateCollectionViewBlock)collectionViewBlock
                  transitionDataBlock:(DBXListUpdateTransitionDataBlock)transitionDataBlock
                applySectionDataBlock:(DBXListUpdateApplyTransitionDataBlock)applySectionDataBlock
                           completion:(nullable DBXListUpdateCompletion)completion;

- (id<DBXListUpdateTransactable>)buildTransaction;

@end

NS_ASSUME_NONNULL_END
