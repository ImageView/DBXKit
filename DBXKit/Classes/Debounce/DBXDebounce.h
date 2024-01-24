//
//  DBXDebounce.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/22.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXDebRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXDebounce : NSObject

+ (instancetype)sharedInstance;

- (void)addRule:(DBXDebRule *)rule;

@end

NS_ASSUME_NONNULL_END
