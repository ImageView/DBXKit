//
//  DBXListDiffIndexResult.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/3.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXListMoveIndex : NSObject

@property(nonatomic, assign, readonly) NSInteger from;
@property(nonatomic, assign, readonly) NSInteger to;
- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to;
@end

// 经过diff后的结果
@interface DBXListDiffIndexResult : NSObject

// 新插入的索引信息
@property(nonatomic, strong, readonly) NSIndexSet *inserts;
// 删除的索引信息
@property(nonatomic, strong, readonly) NSIndexSet *deletes;
@property(nonatomic, strong, readonly) NSIndexSet *updates;
@property(nonatomic, strong, readonly) NSArray <DBXListMoveIndex *> *moves;

- (instancetype)initWithInserts:(NSIndexSet *)inserts
                        deletes:(NSIndexSet *)deletes
                        updates:(NSIndexSet *)updates
                          moves:(NSArray<DBXListMoveIndex *> *)moves
                    oldIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)oldIndexMap
                    newIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)newIndexMap;

- (NSInteger)changeCount;
@end

NS_ASSUME_NONNULL_END
