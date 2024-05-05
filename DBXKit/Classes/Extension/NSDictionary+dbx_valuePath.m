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

// id *需要指定所有权修饰符，否则无法编译，此处指定为__strong
- (void)dbx_valuesForkeyPath:(NSString *)keyPath values:(id _Nonnull __strong *_Nonnull)values, ... NS_REQUIRES_NIL_TERMINATION {
    if (![keyPath isKindOfClass:[NSString class]] || !values) {
        return;
    }
    NSArray *keyList = [keyPath componentsSeparatedByString:@"."];
    id result = self;
    for (NSString *key in keyList) {
        BOOL isDictionary = [result isKindOfClass:[NSDictionary class]];
        NSAssert(isDictionary, @"数据结构和keyPath指定的格式不符");
        if (!isDictionary) {
            return;
        }
        if (key == keyList.lastObject) {
            if ([key containsString:@"&"]) {
                // 有多个对象
                NSArray *objcKeys = [key componentsSeparatedByString:@"&"];
                va_list args;
                va_start(args, values);
                NSInteger index = 0;
                id __strong *currPointer = values;
                do {
                    if (objcKeys.count > index) {
                        NSString *objcKey = objcKeys[index];
                        NSString *k = nil;
                        NSString *cls = nil;
                        if ([objcKey containsString:@"@"]) {
                            NSArray *tempKeys = [objcKey componentsSeparatedByString:@"@"];
                            k = tempKeys.firstObject;
                            cls = tempKeys[1];
                        } else {
                            k = objcKey;
                        }
                        id resultValue = result[k];
                        if (cls && ![resultValue isKindOfClass:NSClassFromString(cls)]) {
                            *currPointer = nil;
                        } else {
                            *currPointer = resultValue;
                        }
                    }
                    index++;
                    currPointer = va_arg(args, id __strong*);
                } while (currPointer != nil);
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
