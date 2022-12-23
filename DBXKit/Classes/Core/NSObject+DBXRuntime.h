//
//  NSObject+DBXRuntime.h
//  DBXKit
//
//  Created by 罗俊宇 on 2022/7/10.
//  Copyright © 2022 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 方法交换
@interface NSObject (DBXRuntime)

+ (BOOL)dbx_swizzleMethod:(SEL)_originSelector newMethod:(SEL)_newSelector error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
