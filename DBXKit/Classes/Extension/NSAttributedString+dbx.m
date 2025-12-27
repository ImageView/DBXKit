//
//  NSAttributedString+dbx.m
//  DBXKit
//
//  Created by 调包侠 on 2023/9/28.
//  Copyright © 2023 DBX. All rights reserved.
//

#import "NSAttributedString+dbx.h"

static NSString const *kDelimiter = @"DBXKit";

@implementation NSAttributedString (dbx)

//- (void)dbx_appendWithConfig:(NSDictionary * (^)(void))configBlock {
//    NSDictionary *config = configBlock();
//    NSString *string = config[@"string"];
//    if (![string isKindOfClass:[NSString class]] || string.length == 0) {
//        return;
//    }
//    NSDictionary *attributes = config[@"attributes"];
//    NSAttributedString *tempAttStr = [[NSAttributedString alloc] initWithString:string attributes:attributes];
//}

- (instancetype)dbx_addAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs delimiter:(NSString *)delimiter {
    NSRange beginRange = [self.string rangeOfString:delimiter.dbx_beginDelimiter];
    NSRange endRange = [self.string rangeOfString:delimiter.dbx_endDelimiter];
    NSInteger rangeLength = endRange.location - (beginRange.location + beginRange.length);
    if (rangeLength <= 0) {
        return self;
    }
    
    NSMutableAttributedString *mutableSelf = (NSMutableAttributedString *)self;
    BOOL isMutable = [self isKindOfClass:[NSMutableAttributedString class]];
    if (!isMutable) {
        mutableSelf = self.mutableCopy;
    }
    
    NSRange range = NSMakeRange(beginRange.location + beginRange.length, rangeLength);
    [mutableSelf addAttributes:attrs range:range];
    [mutableSelf deleteCharactersInRange:endRange];
    [mutableSelf deleteCharactersInRange:beginRange];
    if (!isMutable) {
        return mutableSelf.copy;
    }
    return self;
}


@end


@implementation NSString (dbx)

- (NSString *)dbx_beginDelimiter {
    return [NSString stringWithFormat:@"%@_%@", kDelimiter, self];
}

- (NSString *)dbx_endDelimiter {
    return [NSString stringWithFormat:@"%@_%@", self, kDelimiter];
}

@end
