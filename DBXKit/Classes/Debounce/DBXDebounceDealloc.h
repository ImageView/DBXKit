//
//  DBXDebounceDealloc.h
//  DBXKit
//
//  Created by 调包侠 on 2024/1/27.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXDebounceRule;
@interface DBXDebounceDealloc : NSObject

@property(nonatomic) DBXDebounceRule *rule;
@property (nonatomic) Class cls;

- (void)lock;
- (void)unlock;

@end

NS_ASSUME_NONNULL_END
