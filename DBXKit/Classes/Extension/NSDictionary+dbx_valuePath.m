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

@end
