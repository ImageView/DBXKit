//
//  NSObject+modelValue.m
//  TestTDM1
//
//  Created by DBX on 2021/7/04.
//  Copyright © 2020 diaobaoxia. All rights reserved.
//


#import "NSDictionary+dbx_valuePath.h"

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
    
    id reslut = self;
    for (NSString *key in keyList) {
        if ([reslut isKindOfClass:[NSDictionary class]]) {
            reslut = [(NSDictionary *)reslut objectForKey:key];
        }
    }
    if (cls && ![reslut isKindOfClass:cls]) {
        return nil;
    }
    return reslut;
}

// key1.key2.key3&key4
- (void)dbx_keyPath:(NSString *)keyPath values:(id _Nullable *_Nullable)values, ... NS_REQUIRES_NIL_TERMINATION {
    if (![keyPath isKindOfClass:[NSString class]] || !values) {
        return;
    }
    NSArray *keyList = [keyPath componentsSeparatedByString:@"."];
    id reslut = self;
    for (NSString *key in keyList) {
        if ([key containsString:@"&"]) {
            // 有多个对象
            NSArray *objcKeys = [key componentsSeparatedByString:@"&"];
            va_list args;
            va_start(args, values);
            NSInteger index = 0;
            id __autoreleasing *currentObject = values;
            do {
                NSString *objcKey = objcKeys[index];
                *currentObject = reslut[objcKey];
                currentObject = va_arg(args, id __autoreleasing *);
                index++;
            } while (currentObject != nil);
            va_end(args); // 清理工作
        } else if ([reslut isKindOfClass:[NSDictionary class]]) {
            reslut = [(NSDictionary *)reslut objectForKey:key];
        }
    }
}

@end
