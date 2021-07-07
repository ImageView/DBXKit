//
//  NSObject+modelValue.m
//  TestTDM1
//
//  Created by 调包侠 on 2021/7/04.
//  Copyright © 2020 diaobaoxia. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 取字典更深层次的值
@interface NSDictionary (dbx_valuePath)

// keypath以.隔开
- (id)dbx_valueForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
