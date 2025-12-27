//
//  DBXListBatchUpdateData.m
//  DBXKit
//
//  Created by 调包侠 on 2025/11/21.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListBatchUpdateData.h"
#import <UIKit/UIKit.h>
#import <unordered_map>
#import "DBXListDiffIndexResult.h"
#import "DBXListBatchUpdateData.h"
#import "DBXListMoveIndexPath.h"


static void convertMoveToDeleteAndInsert(NSMutableSet<DBXListMoveIndex *> *moves,
                                         DBXListMoveIndex *move,
                                         NSMutableIndexSet *deletes,
                                         NSMutableIndexSet *inserts) {
    [moves removeObject:move];
    [deletes addIndex:move.from];
    [inserts addIndex:move.to];
}

@implementation DBXListBatchUpdateData

// Converts all section moves that have index path operations into a section delete + insert.
+ (void)_cleanIndexPathsWithMap:(const std::unordered_map<NSInteger, DBXListMoveIndex*> &)map
                         moves:(NSMutableSet<DBXListMoveIndex *> *)moves
                    indexPaths:(NSMutableArray<NSIndexPath *> *)indexPaths
                       deletes:(NSMutableIndexSet *)deletes
                       inserts:(NSMutableIndexSet *)inserts {
    if (indexPaths.count == 0) {
        return;
    }
    for (NSInteger i = indexPaths.count - 1; i >= 0; i--) {
        NSIndexPath *path = indexPaths[i];
        const auto it = map.find(path.section);
        if (it != map.end() && it->second != nil) {
            [indexPaths removeObjectAtIndex:i];
            convertMoveToDeleteAndInsert(moves, it->second, deletes, inserts);
        }
    }
}

- (instancetype)initWithInsertSections:(nonnull NSIndexSet *)insertSections
                        deleteSections:(nonnull NSIndexSet *)deleteSections
                          moveSections:(nonnull NSSet<DBXListMoveIndex *> *)moveSections
                      insertIndexPaths:(nonnull NSArray<NSIndexPath *> *)insertIndexPaths
                      deleteIndexPaths:(nonnull NSArray<NSIndexPath *> *)deleteIndexPaths
                      updateIndexPaths:(nonnull NSArray<NSIndexPath *> *)updateIndexPaths
                        moveIndexPaths:(nonnull NSArray<DBXListMoveIndexPath *> *)moveIndexPaths {

    if (self = [super init]) {
        NSMutableSet<DBXListMoveIndex *> *mMoveSections = [moveSections mutableCopy];
        NSMutableIndexSet *mDeleteSections = [deleteSections mutableCopy];
        NSMutableIndexSet *mInsertSections = [insertSections mutableCopy];
        NSMutableSet<DBXListMoveIndexPath *> *mMoveIndexPaths = [moveIndexPaths mutableCopy];

        const NSInteger moveCount = [moveSections count];
        std::unordered_map<NSInteger, DBXListMoveIndex*> fromMap(MAX(moveCount, 1));
        std::unordered_map<NSInteger, DBXListMoveIndex*> toMap(MAX(moveCount, 1));
        for (DBXListMoveIndex *move in moveSections) {
            const NSInteger from = move.from;
            const NSInteger to = move.to;

            // if the move is already deleted or inserted, discard it because count-changing operations must match
            // with data source changes
            if ([deleteSections containsIndex:from] || [insertSections containsIndex:to]) {
                [mMoveSections removeObject:move];
            } else {
                fromMap[from] = move;
                toMap[to] = move;
            }
        }

        NSMutableArray<NSIndexPath *> *mDeleteIndexPaths;
        NSMutableArray<NSIndexPath *> *mInsertIndexPaths;

        // Avoid a flaky UICollectionView bug when deleting from the same index path twice
        // exposes a possible data source inconsistency issue
        NSMutableDictionary<NSIndexPath *, NSNumber *> *const deleteCounts = [NSMutableDictionary new];

        // If we need to remove a duplicate delete, we also need to remove an insert to balance the count.
        // Lets build the delete counts for each index, which we can use to skip corresponding inserts.
        for (NSIndexPath *deleteIndexPath in deleteIndexPaths) {
            const NSInteger deleteCount = deleteCounts[deleteIndexPath].integerValue;
            deleteCounts[deleteIndexPath] = @(deleteCount + 1);
        }

        // Skip inserts that have an associated skipped delete
        NSMutableArray<NSIndexPath *> *const trimmedInsertIndexPath = [NSMutableArray new];
        for (NSIndexPath *insertIndexPath in insertIndexPaths) {
            const NSInteger deleteCount = deleteCounts[insertIndexPath].integerValue;
            if (deleteCount > 1) {
                // Skip!
                deleteCounts[insertIndexPath] = @(deleteCount - 1);
            } else {
                [trimmedInsertIndexPath addObject:insertIndexPath];
            }
        }

        mDeleteIndexPaths = [[deleteCounts allKeys] mutableCopy];
        mInsertIndexPaths = trimmedInsertIndexPath;


        // avoids a bug where a cell is animated twice and one of the snapshot cells is never removed from the hierarchy
        [DBXListBatchUpdateData _cleanIndexPathsWithMap:fromMap moves:mMoveSections indexPaths:mDeleteIndexPaths deletes:mDeleteSections inserts:mInsertSections];

        // prevents a bug where UICollectionView corrupts the heap memory when inserting into a section that is moved
        [DBXListBatchUpdateData _cleanIndexPathsWithMap:toMap moves:mMoveSections indexPaths:mInsertIndexPaths deletes:mDeleteSections inserts:mInsertSections];

        for (DBXListMoveIndexPath *move in moveIndexPaths) {
            // if the section w/ an index path move is deleted, just drop the move
            if ([deleteSections containsIndex:move.from.section]) {
                [mMoveIndexPaths removeObject:move];
            }

            // if a move is inside a section that is moved, convert the section move to a delete+insert
            const auto it = fromMap.find(move.from.section);
            if (it != fromMap.end() && it->second != nil) {
                DBXListMoveIndex *sectionMove = it->second;
                [mMoveIndexPaths removeObject:move];
                [mMoveSections removeObject:sectionMove];
                [mDeleteSections addIndex:sectionMove.from];
                [mInsertSections addIndex:sectionMove.to];
            }
        }

        _deleteSections = [mDeleteSections copy];
        _insertSections = [mInsertSections copy];
        _moveSections = [mMoveSections copy];
        _deleteIndexPaths = [mDeleteIndexPaths copy];
        _insertIndexPaths = [mInsertIndexPaths copy];
        _updateIndexPaths = [updateIndexPaths copy];
        _moveIndexPaths = [mMoveIndexPaths copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if ([object isKindOfClass:[DBXListBatchUpdateData class]]) {
        return ([self.insertSections isEqual:[object insertSections]]
                && [self.deleteSections isEqual:[object deleteSections]]
                && [self.moveSections isEqual:[object moveSections]]
                && [self.insertIndexPaths isEqual:[object insertIndexPaths]]
                && [self.deleteIndexPaths isEqual:[object deleteIndexPaths]]
                && [self.updateIndexPaths isEqual:[object updateIndexPaths]]
                && [self.moveIndexPaths isEqual:[object moveIndexPaths]]);
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; deleteSections: %lu; insertSections: %lu; moveSections: %lu; deleteIndexPaths: %lu; insertIndexPaths: %lu; updateIndexPaths: %lu>",
            NSStringFromClass(self.class), self, (unsigned long)self.deleteSections.count, (unsigned long)self.insertSections.count, (unsigned long)self.moveSections.count,
            (unsigned long)self.deleteIndexPaths.count, (unsigned long)self.insertIndexPaths.count, (unsigned long)self.updateIndexPaths.count];
}

@end
