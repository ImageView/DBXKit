//
//  DBXListArrayWrapper.m
//  DBXKit
//
//  Created by 调包侠 on 2025/11/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListArrayWrapper.h"

@interface DBXListArrayWrapper ()
// 自定义唯一标识
@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;
// 包含的数组对象
@property (nonatomic, copy, readwrite) NSArray <DBXListDiffable> *items;

@end

@implementation DBXListArrayWrapper

- (instancetype)initWithItems:(NSArray *)items uniqueIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _items = [items copy];
        _uniqueIdentifier = [identifier copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DBXListArrayWrapper *obj = [[self class] allocWithZone:zone];
    obj.items = self.items;
    obj.uniqueIdentifier = self.uniqueIdentifier;
    
    return obj;
}
#pragma mark - IGListDiffable

- (id)diffIdentifier {
    return self.uniqueIdentifier;
}

- (BOOL)isEqualToDiffObject:(id<DBXListDiffable>)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[DBXListArrayWrapper class]]) return NO;
    
    DBXListArrayWrapper *other = (DBXListArrayWrapper *)object;
    
    // 比较两个包装器是否"相等"
    return [self.uniqueIdentifier isEqualToString:other.uniqueIdentifier] &&
           [self.items isEqualToArray:other.items]; // 深度比较数组内容
}
@end
