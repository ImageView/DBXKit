//
//  DBXListDiff.m
//  DBXKit
//
//  Created by 调包侠 on 2025/8/3.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListDiff.h"
#import <stack>
#import <unordered_map>
#import <vector>
#import "DBXListDiffable.h"
#import "DBXListDiffIndexResult.h"

using namespace std;

struct DBXListEntry {
    NSInteger oldCounter = 0;
    NSInteger newCounter = 0;
    stack<NSInteger> oldIndexes;
    BOOL updated = NO;
};

struct DBXListRecord {
    DBXListEntry *entry;
    mutable NSInteger index;

    DBXListRecord() {
        entry = NULL;
        index = NSNotFound;
    }
};

static id<NSObject> DBXListTableKey(__unsafe_unretained id<DBXListDiffable> object) {
    id<NSObject> key = [object diffIdentifier];
    NSCAssert(key != nil, @"diffIdentifier Cannot be nil for object %@", object);
    return key;
}

struct DBXListEqualID {
    bool operator()(const id a, const id b) const {
        return (a == b) || [a isEqual: b];
    }
};

struct DBXListHashID {
    size_t operator()(const id o) const {
        return (size_t)[o hash];
    }
};

@implementation DBXListDiff

+ (DBXListDiffIndexResult *)listDiffingWithOldArray:(NSArray *)oldArray newArray:(NSArray *)newArray option:(DBXListDiffOption)option {
    NSInteger newCount = newArray.count;
    NSInteger oldCount = oldArray.count;

    NSMapTable *oldMap = [NSMapTable strongToStrongObjectsMapTable];
    NSMapTable *newMap = [NSMapTable strongToStrongObjectsMapTable];
    
    if (newCount == 0) {
        [oldArray enumerateObjectsUsingBlock:^(id<DBXListDiffable> obj, NSUInteger idx, BOOL *stop) {
            [self addIndexToMapWithSection:0 index:idx object:obj map:oldMap];
        }];
        return [[DBXListDiffIndexResult alloc] initWithInserts:[NSIndexSet new]
                                                     deletes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldCount)]
                                                     updates:[NSIndexSet new]
                                                       moves:[NSArray new]
                                                 oldIndexMap:oldMap
                                                 newIndexMap:newMap];
    }
    
    if (oldCount == 0) {
        [newArray enumerateObjectsUsingBlock:^(id<DBXListDiffable> obj, NSUInteger idx, BOOL *stop) {
            [self addIndexToMapWithSection:0 index:idx object:obj map:newMap];
        }];
        return [[DBXListDiffIndexResult alloc] initWithInserts:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newCount)]
                                                     deletes:[NSIndexSet new]
                                                     updates:[NSIndexSet new]
                                                       moves:[NSArray new]
                                                 oldIndexMap:oldMap
                                                 newIndexMap:newMap];
    }

    unordered_map<id<NSObject>, DBXListEntry, DBXListHashID, DBXListEqualID> table;
    
    vector<DBXListRecord> newResultsArray(newCount);
    for (NSInteger i = 0; i < newCount; i++) {
        id<NSObject> key = DBXListTableKey(newArray[i]);
        DBXListEntry &entry = table[key];
        entry.newCounter++;
        entry.oldIndexes.push(NSNotFound);
        newResultsArray[i].entry = &entry;
    }
    
    vector<DBXListRecord> oldResultsArray(oldCount);
    for (NSInteger i = oldCount - 1; i >= 0; i--) {
        id<NSObject> key = DBXListTableKey(oldArray[i]);
        DBXListEntry &entry = table[key];
        entry.oldCounter++;
        entry.oldIndexes.push(i);
        oldResultsArray[i].entry = &entry;
    }

    for (NSInteger i = 0; i < newCount; i++) {
        DBXListEntry *entry = newResultsArray[i].entry;

        NSCAssert(!entry->oldIndexes.empty(), @"Old indexes is empty while iterating new item %li. Should have NSNotFound", (long)i);
        const NSInteger originalIndex = entry->oldIndexes.top();
        entry->oldIndexes.pop();

        if (originalIndex < oldCount) {
            id<DBXListDiffable> n = newArray[i];
            id<DBXListDiffable> o = oldArray[originalIndex];
            switch (option) {
                case DBXListDiffOptionPointer:
                    if (n != o) {
                        entry->updated = YES;
                    }
                    break;
                case DBXListDiffOptionListDiffEquality:
                    if (n != o && ![n isEqualToDiffObject:o]) {
                        entry->updated = YES;
                    }
                    break;
                default:
                    ;
            }
        }
        if (originalIndex != NSNotFound
            && entry->newCounter > 0
            && entry->oldCounter > 0) {
            newResultsArray[i].index = originalIndex;
            oldResultsArray[originalIndex].index = i;
        }
    }

    id mInserts, mMoves, mUpdates, mDeletes;
    
    mInserts = [NSMutableIndexSet new];
    mMoves = [NSMutableArray<DBXListMoveIndex *> new];
    mUpdates = [NSMutableIndexSet new];
    mDeletes = [NSMutableIndexSet new];
    

    vector<NSInteger> deleteOffsets(oldCount), insertOffsets(newCount);
    NSInteger runningOffset = 0;
    
    for (NSInteger i = 0; i < oldCount; i++) {
        deleteOffsets[i] = runningOffset;
        const DBXListRecord record = oldResultsArray[i];
        if (record.index == NSNotFound) {
            [mDeletes addIndex:i];
            runningOffset++;
        }
        [self addIndexToMapWithSection:0 index:i object:oldArray[i] map:oldMap];
    }

    runningOffset = 0;

    for (NSInteger i = 0; i < newCount; i++) {
        insertOffsets[i] = runningOffset;
        const DBXListRecord record = newResultsArray[i];
        const NSInteger oldIndex = record.index;
        
        if (record.index == NSNotFound) {
            [mInserts addIndex:i];
            runningOffset++;
        } else {
            if (record.entry->updated) {
                [mUpdates addIndex:oldIndex];
            }

            const NSInteger insertOffset = insertOffsets[i];
            const NSInteger deleteOffset = deleteOffsets[oldIndex];
            if ((oldIndex - deleteOffset + insertOffset) != i) {
                id move = [[DBXListMoveIndex alloc] initWithFrom:oldIndex to:i];
                [mMoves addObject:move];
            }
        }
        [self addIndexToMapWithSection:0 index:i object:newArray[i] map:newMap];
    }

    NSCAssert((oldCount + (NSInteger)[mInserts count] - (NSInteger)[mDeletes count]) == newCount,
              @"数量检查失败，有%lu条新增和%lu条删除，原始数组有%li条，新的数组有%li条",
              (unsigned long)[mInserts count], (unsigned long)[mDeletes count], (long)oldCount, (long)newCount);

    return [[DBXListDiffIndexResult alloc] initWithInserts:mInserts
                                                 deletes:mDeletes
                                                 updates:mUpdates
                                                   moves:mMoves
                                             oldIndexMap:oldMap
                                             newIndexMap:newMap];
}

+ (void)addIndexToMapWithSection:(NSInteger)section index:(NSInteger)index object:( __unsafe_unretained id<DBXListDiffable>)object map:(__unsafe_unretained NSMapTable *)map {
    id value = @(index);
    [map setObject:value forKey:[object diffIdentifier]];
}


@end
