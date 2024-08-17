//
//  Animal.m
//  DBXKit
//
//  Created by asherluo on 2023/1/27.
//  Copyright © 2023 调包侠. All rights reserved.
//

#import "Animal.h"
#import <objc/runtime.h>

@interface Animal ()

@property(nonatomic, strong) NSMutableDictionary *countDic;
@end
@implementation Animal
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.countDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@>", object_getClass(self), _name];
}

- (void)eat:(NSString *)food {
    NSLog(@"吃%@,%s,%@", food, __func__, self.name);
}

- (void)eatFood:(NSString *)food {
    @synchronized (self) {
        NSLog(@"%s,%@(real:%@)吃%@", __func__, self.name, object_getClass(self), food);
        int count = [self countOfFood:food];
        count ++;
        [self.countDic setObject:@(count) forKey:food];
    }
}

- (int)countOfFood:(NSString *)food {
    @synchronized (self) {
        NSNumber *count = [self.countDic objectForKey:food];
        return count.intValue;
    }
}

- (void)testNumber:(int)num {
    NSLog(@"%d", num);
}

- (void)run {
    NSLog(@"跑%s,%@", __func__, _name);
}

- (void)barking {
    NSLog(@"叫%s,%@", __func__, self.name);
}
@end
