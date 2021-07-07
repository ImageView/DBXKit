//
//  NSObject+modelValue.m
//  TestTDM1
//
//  Created by 调包侠 on 2021/7/04.
//  Copyright © 2020 diaobaoxia. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (dbx_modelValue)

/*
配置数组属性的元素类型
如：有属性名为subViews，类型是NSArray，元素类名为UIView，需要配置 @{@"subViews" : @"UIView"}
需要在子类重写此方法，没有重写则数组属性的值均为nil
*/
+ (NSDictionary *)dbx_arrayPropertyConfig;

+ (NSArray *)dbx_modelArrayWithKeyValues:(NSArray *)keyValuesArray;

+ (instancetype)dbx_modelWithKeyValues:(NSDictionary *)keyValues;

- (instancetype)dbx_setValuesFromKeyValues:(NSDictionary *)keyValues;

@end

NS_ASSUME_NONNULL_END
