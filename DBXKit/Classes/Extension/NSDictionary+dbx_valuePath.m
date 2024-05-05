//
//  NSObject+modelValue.m
//  TestTDM1
//
//  Created by DBX on 2021/7/04.
//  Copyright © 2020 diaobaoxia. All rights reserved.
//


#import "NSDictionary+dbx_valuePath.h"
#import "DBXLog.h"

// 取字典更深层次的值
@implementation NSDictionary (dbx_valuePath)

- (id)dbx_valueForKeyPath:(NSString *)keyPath {
    return [self dbx_valueForKeyPath:keyPath limitedClass:nil];
}

- (id)dbx_valueForKeyPath:(NSString *)keyPath limitedClass:(Class _Nullable)cls {
    if (![keyPath isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSArray *keyList = [keyPath componentsSeparatedByString:@"."];
    
    id result = self;
    for (NSString *key in keyList) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            result = [(NSDictionary *)result objectForKey:key];
        }
    }
    if (cls && ![result isKindOfClass:cls]) {
        return nil;
    }
    return result;
}

// key1.key2.key3&key4
- (void)dbx_valuesForkeyPath:(NSString *)keyPath values:(id _Nonnull __autoreleasing *_Nonnull)values, ... NS_REQUIRES_NIL_TERMINATION {
    if (![keyPath isKindOfClass:[NSString class]] || !values) {
        return;
    }
    NSArray *keyList = [keyPath componentsSeparatedByString:@"."];
    id result = self;
    for (NSString *key in keyList) {
        NSAssert([result isKindOfClass:[NSDictionary class]], @"数据结构错误");
        if (key == keyList.lastObject) {
            if ([key containsString:@"&"]) {
                // 有多个对象
                NSArray *objcKeys = [key componentsSeparatedByString:@"&"];
                va_list args;
                va_start(args, values);
                NSInteger index = 0;
                id __autoreleasing *currPointer = values;
                do {
                    NSString *objcKey = objcKeys[index];
                    *currPointer = result[objcKey];
                    index++;
                    DBXLog(@"currPointer=%p, value=%@", currPointer, *currPointer);
                    currPointer = va_arg(args, id __autoreleasing *);
                } while (currPointer != nil);
                DBXLog(@"result = %@ address = %p", result, result);
                va_end(args);
            } else {
                // 单个对象
                *values = result[key];
            }
        } else {
            result = result[key];
        }
    }
}

@end
