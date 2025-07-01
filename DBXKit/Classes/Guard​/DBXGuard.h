//
//  DBXGuard.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/6/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXGuard : NSObject

+ (void)disableClassName:(NSString *)className methods:(NSString *)methods;

@end

NS_ASSUME_NONNULL_END
