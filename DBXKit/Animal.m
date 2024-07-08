//
//  Animal.m
//  DBXKit
//
//  Created by asherluo on 2023/1/27.
//  Copyright © 2023 调包侠. All rights reserved.
//

#import "Animal.h"

@implementation Animal
- (void)eat:(NSString *)food {
    NSLog(@"吃%@,%s,%@", food, __func__, self.name);
}

- (void)run {
    NSLog(@"跑%s,%@", __func__, self.name);
}

- (void)barking {
    NSLog(@"叫%s,%@", __func__, self.name);
}
@end
