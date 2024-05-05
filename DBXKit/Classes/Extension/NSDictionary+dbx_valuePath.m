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
- (void)dbx_valuesForkeyPath:(NSString *)keyPath values:(id __autoreleasing * )values, ... NS_REQUIRES_NIL_TERMINATION {
    if (![keyPath isKindOfClass:[NSString class]] || !values) {
        return;
    }
    NSArray *keyList = [keyPath componentsSeparatedByString:@"."];
    id reslut = self;
    for (NSString *key in keyList) {
        NSAssert([reslut isKindOfClass:[NSDictionary class]], @"数据结构错误");
        if (key == keyList.lastObject) {
            if ([key containsString:@"&"]) {
                // 有多个对象
                NSArray *objcKeys = [key componentsSeparatedByString:@"&"];
                va_list args;
                va_start(args, values);
                NSInteger index = 0;
                id __autoreleasing * currentObject = values;
                do {
                    NSString *objcKey = objcKeys[index];
                    *currentObject = reslut[objcKey];
                    index++;
                    DBXLog(@"currentObject=%p, value=%@", currentObject, *currentObject);
                    currentObject = va_arg(args, id __autoreleasing *);
                } while (currentObject != nil);
                DBXLog(@"result = %@ address = %p", reslut, &reslut);
                va_end(args);
            } else {
                // 单个对象
                *values = reslut[key];
            }
        } else {
            reslut = reslut[key];
        }
    }
}


//- (void)dbx_valuesForKeyPath:(NSString *)keyPath values:(id *)firstValue, ... NS_REQUIRES_NIL_TERMINATION {
//    if (![keyPath isKindOfClass:[NSString class]] || !firstValue) {
//        return;
//    }
//    
//    NSArray *keyList = [keyPath componentsSeparatedByString:@"."];
//    id result = self;
//    for (NSString *key in keyList) {
//        if (![result isKindOfClass:[NSDictionary class]]) {
//            NSLog(@"数据结构错误，期望的是NSDictionary类型，实际上是：%@", [result class]);
//            return;
//        }
//        
//        if (key == keyList.lastObject && [key containsString:@"&"]) {
//            NSArray *objcKeys = [key componentsSeparatedByString:@"&"];
//            va_list args;
//            va_start(args, firstValue);
//            *firstValue = [result objectForKey:objcKeys[0]]; // Set the first value
//            
//            if (objcKeys.count > 1) {
//                id __autoreleasing *currentObject = va_arg(args, id __autoreleasing *);
//                for (NSUInteger i = 1; i < objcKeys.count; i++) {
//                    NSString *objcKey = objcKeys[i];
//                    if (currentObject) {
//                        *currentObject = [result objectForKey:objcKey];
//                        currentObject = va_arg(args, id __autoreleasing *);
//                    } else {
//                        break;
//                    }
//                }
//            }
//            va_end(args);
//        } else {
//            result = [(NSDictionary *)result objectForKey:key];
//        }
//    }
//    
//    if (![keyPath containsString:@"&"]) {
//        *firstValue = result;
//    }
//}
@end
