//
//  NSObject+modelValue.m
//  TestTDM1
//
//  Created by DBX on 2021/7/04.
//  Copyright © 2020 diaobaoxia. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 取字典更深层次的值
@interface NSDictionary (dbx_valuePath)

/// 解析多层字典
/// @param keyPath key路径，以.隔开
/// @param cls 限定返回Class，传nil表示不限定
- (id)dbx_valueForKeyPath:(NSString *)keyPath limitedClass:(Class _Nullable)cls;

/// 解析多层字典
/// @param keyPath key路径，以.隔开
- (id)dbx_valueForKeyPath:(NSString *)keyPath;

// 以nil结束


///  解析多个字段
/// @param keyPath key路径
/// @param values 返回值的指针，调用获取到值后需自行处理数据类型安全

/**
 用于取同一个层级下的多个对象，如
 @"content" : @{
    @"name" :  @"asher",
    @"sex" : @(1),
    @"playgame":@{
        @"wangzhe" : @"100",
        @"heping" : @"99"
    }
 }
 */
// 要取name，sex，playgame，的值，调用方式为
// NSString *name;
// NSString *sex;
// NSDictionary *games;
// [dictionary dbx_keyPath:@"content.name&sex&playgame" values:&name, &sex, &games];
// 如果要指定字段类型，在keyPath的字段key后面拼接@及类名，如@"content.name&sex@NSString&playgame@NSDictionary"
- (void)dbx_valuesForkeyPath:(NSString *)keyPath values:(id _Nonnull __strong *_Nonnull)values, ... NS_REQUIRES_NIL_TERMINATION;
@end

NS_ASSUME_NONNULL_END
