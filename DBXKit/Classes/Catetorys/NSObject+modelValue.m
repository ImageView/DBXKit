//
//  NSObject+modelValue.m
//  TestTDM1
//
//  Created by 调包侠 on 2021/7/04.
//  Copyright © 2020 diaobaoxia. All rights reserved.
//

#import "NSObject+modelValue.h"
#import <objc/runtime.h>

@implementation NSObject (modelValue)

/*
 配置数组属性的元素类型
 如：有属性名为subViews，类型是NSArray，元素类名为UIView，需要配置 @{@"subViews" : @"UIView"}
 需要在子类重写此方法，没有重写则数组属性的值均为nil
 */
+ (NSDictionary *)arrayPropertyConfig
{
    return nil;
}

// NSDictionarys -> Models
+ (NSArray *)modelArrayWithKeyValues:(NSArray *)keyValuesArray
{
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSDictionary *modelDic in keyValuesArray) {
        id model = [self modelWithKeyValues:modelDic];
        [tempArr addObject:model];
    }
    return [tempArr copy];
}

// NSDictionary -> Model
+ (instancetype)modelWithKeyValues:(NSDictionary *)keyValues
{
    return [self modelWithKeyValues:keyValues arraysClassConfig:[self arrayPropertyConfig]];
}

// 给self填充value，数据来源自NSDictionary
- (instancetype)setValuesFromKeyValues:(NSDictionary *)keyValues
{
    return [self setValuesFromKeyValues:keyValues arraysClassConfig:[self.class arrayPropertyConfig]];
}

+ (instancetype)modelWithKeyValues:(NSDictionary *)keyValues arraysClassConfig:(NSDictionary *)classConfig
{
    id model = [[self alloc] init];
    [model setValuesFromKeyValues:keyValues arraysClassConfig:classConfig];
    return model;
}

- (instancetype)setValuesFromKeyValues:(NSDictionary *)keyValues arraysClassConfig:(NSDictionary *)classConfig
{
    if (![keyValues isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"%s__parmes须是NSDictrionary",__func__);
        return nil;
    }
    
    unsigned int proCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &proCount);
    if (proCount == 0) {
        return nil;
    }
    for (unsigned int i = 0; i < proCount; i++) {
        NSString *proName = [NSString stringWithUTF8String:property_getName(properties[i])];

        if (!proName) {
            continue;
        }
        id value = keyValues[proName];
        
        // 处理属性中包含数组的情况
        if ([value isKindOfClass:[NSArray class]]) {
            if (!classConfig || classConfig.count == 0) {
                continue; // 当没有配置classConfig时，会将字典数组直接复制过去，这不是预期中的，因此在这里加个屏蔽
            }
            NSString *className = classConfig[proName];
            if (!className || className.length == 0) {
                continue;
            }
            Class cls = NSClassFromString(className);
            if (!cls) {
                continue;
            }
            NSMutableArray *valueList = [NSMutableArray array];
            NSArray *array = (NSArray *)value;
            for (int j = 0; j < array.count; j++) {
                id model = [cls modelWithKeyValues:array[j]];
                if (model && [model isKindOfClass:cls]) {
                    [valueList addObject:model];
                }
            }
            value = valueList;
        }
        
        if (value && ![value isKindOfClass:[NSNull class]]) {  // 过滤NSNull
            NSString *proType = [NSString stringWithUTF8String:property_getAttributes(properties[i])];
            [self setValue:[self getValue:value type:proType] forKey:proName];
        }
    }
    free(properties);
    
    return self;
}

// 判断当前Model的属性类型，针对类型进行数据转换，不然直接调用setValue可能会抛异常
- (id)getValue:(id)value type:(NSString *)proType
{
    // 鉴于NSString作为属性的概率最大，优先判断NSString类型，减少比较次数
    if ([proType hasPrefix:@"T@\"NSString\""]) {
        return value;
    }
    
    id number;
    if ([proType hasPrefix:@"TQ"]) {
        number = [[NSNumber alloc] initWithInteger:[value integerValue]];
    } else if ([proType hasPrefix:@"Ti"]) {
       number = [[NSNumber alloc] initWithInt:[value intValue]];
    } else if ([proType hasPrefix:@"Td"]) {
        number = [[NSNumber alloc] initWithDouble:[value doubleValue]];
    } else if ([proType hasPrefix:@"Tf"]) {
        number = [[NSNumber alloc] initWithFloat:[value floatValue]];
    } else if ([proType hasPrefix:@"Ts"]) {
        number = [[NSNumber alloc] initWithShort:[value shortValue]];
    } else if ([proType hasPrefix:@"Tq"]) {
        number = [[NSNumber alloc] initWithLongLong:[value longLongValue]];
    } else if ([proType hasPrefix:@"TB"]) {
        number = [[NSNumber alloc] initWithBool:[value boolValue]];
    } else if ([proType hasPrefix:@"Tc"]) {
        number = [[NSNumber alloc] initWithChar:[value charValue]];
    } else {
        number = value;
    }
    
    return number;
}

@end
