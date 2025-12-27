//
//  DBXListDiff.h
//  DBXKit
//
//  Created by 调包侠 on 2025/8/3.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXListDiffIndexResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DBXListDiffOption) {
    DBXListDiffOptionPointer,
    DBXListDiffOptionListDiffEquality
};

@interface DBXListDiff : NSObject

+ (DBXListDiffIndexResult *)listDiffingWithOldArray:(NSArray *)oldArray newArray:(NSArray *)newArray option:(DBXListDiffOption)option;

@end

NS_ASSUME_NONNULL_END
