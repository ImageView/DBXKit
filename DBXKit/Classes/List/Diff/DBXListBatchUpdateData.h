//
//  DBXListBatchUpdateData.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/11/21.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXListMoveIndex;
@class DBXListMoveIndexPath;
@interface DBXListBatchUpdateData : NSObject

@property (nonatomic, strong, readonly) NSIndexSet *insertSections;
@property (nonatomic, strong, readonly) NSIndexSet *deleteSections;
@property (nonatomic, strong, readonly) NSSet<DBXListMoveIndex *> *moveSections;
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *insertIndexPaths;
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *deleteIndexPaths;
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *updateIndexPaths;
@property (nonatomic, strong, readonly) NSArray<DBXListMoveIndexPath *> *moveIndexPaths;

/**
 Creates a new batch update object with section and item operations.

 @param insertSections Section indexes to insert.
 @param deleteSections Section indexes to delete.
 @param moveSections Section moves.
 @param insertIndexPaths Item index paths to insert.
 @param deleteIndexPaths Item index paths to delete.
 @param updateIndexPaths Item index paths to update.
 @param moveIndexPaths Item index paths to move.


 @return A new batch update object.
 */
- (instancetype)initWithInsertSections:(NSIndexSet *)insertSections
                        deleteSections:(NSIndexSet *)deleteSections
                          moveSections:(NSSet<DBXListMoveIndex *> *)moveSections
                      insertIndexPaths:(NSArray<NSIndexPath *> *)insertIndexPaths
                      deleteIndexPaths:(NSArray<NSIndexPath *> *)deleteIndexPaths
                      updateIndexPaths:(NSArray<NSIndexPath *> *)updateIndexPaths
                        moveIndexPaths:(NSArray<DBXListMoveIndexPath *> *)moveIndexPaths NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
