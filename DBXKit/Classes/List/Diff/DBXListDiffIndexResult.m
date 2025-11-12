//
//  DBXListDiffIndexResult.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/3.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListDiffIndexResult.h"

@implementation DBXListMoveIndex
- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to {
    if (self = [super init]) {
        _from = from;
        _to = to;
    }
    return self;
}
@end

@implementation DBXListDiffIndexResult{
    NSMapTable<id<NSObject>, NSNumber *> *_oldIndexMap;
    NSMapTable<id<NSObject>, NSNumber *> *_newIndexMap;
}

- (instancetype)initWithInserts:(NSIndexSet *)inserts
                        deletes:(NSIndexSet *)deletes
                        updates:(NSIndexSet *)updates
                          moves:(NSArray<DBXListMoveIndex *> *)moves
                    oldIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)oldIndexMap
                    newIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)newIndexMap {
    if (self = [super init]) {
        _inserts = inserts;
        _deletes = deletes;
        _updates = updates;
        _moves = moves;
        _oldIndexMap = oldIndexMap;
        _newIndexMap = newIndexMap;
    }
    return self;
}

- (NSInteger)changeCount {
    return self.inserts.count + self.deletes.count + self.updates.count + self.moves.count;
}

@end
