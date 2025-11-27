//
//  DBXListArrayWrapper.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/11/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXListDiffable.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXListArrayWrapper : NSObject<DBXListDiffable, NSCopying>

// 自定义唯一标识
@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;
// 包含的数组对象
@property (nonatomic, copy, readonly) NSArray <DBXListDiffable> *items;

- (instancetype)initWithItems:(NSArray <DBXListDiffable> *)items uniqueIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
