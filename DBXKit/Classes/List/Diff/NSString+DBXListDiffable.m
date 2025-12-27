//
//  NSString+DBXListDiffable.h
//  DBXKit
//
//  Created by 调包侠 on 2025/8/3.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "NSString+DBXListDiffable.h"

@implementation NSString (DBXListDiffable)

- (id)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffObject:(id<DBXListDiffable>)object {
    return [self isEqual:object];
}

@end
