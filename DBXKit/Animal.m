//
//  Animal.m
//  DBXKit
//
//  Created by asherluo on 2023/1/27.
//  Copyright © 2023 调包侠. All rights reserved.
//

#import "Animal.h"

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

- (void)eat:(NSString *)food {
    NSLog(@"吃%@,%s,%@", food, __func__, self.name);
}

- (void)addEat:(NSString *)food {
    NSLog(@"吃%@,%s,%@", food, __func__, self.name);

    int count = [self countOfFood:food];
    count ++;
    [self.countDic setObject:@(count) forKey:food];
}

- (int)countOfFood:(NSString *)food {
    NSNumber *count = [self.countDic objectForKey:food];
    return count.intValue;
}


- (void)run {
    NSLog(@"跑%s,%@", __func__, self.name);
}

- (void)barking {
    NSLog(@"叫%s,%@", __func__, self.name);
}
@end
