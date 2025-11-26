//
//  NSString+DBXListDiffable.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/3.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "NSString+DBXListDiffable.h"

@implementation NSObject (DBXListDiffable)

- (id)diffIdentifier {
    return @(self.hash);
}

- (BOOL)isEqualToDiffObject:(id<DBXListDiffable>)object {
    return [self isEqual:object];
}

@end

@implementation NSString (DBXListDiffable)

- (id)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffObject:(id<DBXListDiffable>)object {
    return [self isEqual:object];
}

@end
