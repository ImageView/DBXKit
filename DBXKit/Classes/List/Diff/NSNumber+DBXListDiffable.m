//
//  NSNumber+DBXListDiffable.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/3.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "NSNumber+DBXListDiffable.h"

@implementation NSNumber (DBXListDiffable)

- (id)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffObject:(id<DBXListDiffable>)object {
    return [self isEqual:object];
}

@end
