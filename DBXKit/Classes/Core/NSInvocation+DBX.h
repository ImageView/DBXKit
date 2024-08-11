//
//  NSInvocation+DBX.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/11.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 方法交换
@interface NSInvocation (DBX)

// 获取参数列表
- (NSArray *)dbx_getArgumes;

// 获取返回值，需要invocate之后
- (id)dbx_getReturnValue;

@end

NS_ASSUME_NONNULL_END
