//
//  NSObject+modelValue.m
//  TestTDM1
//
//  Created by 调包侠 on 2021/7/04.
//  Copyright © 2020 diaobaoxia. All rights reserved.
//


#import "NSDictionary+valuePath.h"

// 取字典更深层次的值
@implementation NSDictionary (valuePath)


- (id)valueForKeyPath:(NSString *)keyPath
{
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
    return reslut;
}

@end
