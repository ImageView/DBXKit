//
//  DBXSyringeInterface+DBXSy.m
//  DBXKit
//
//  Created by 调包侠 on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeInterface+DBXSy.h"
#import "DBXRuntimeUtils.h"

@implementation DBXSyringeInterface (DBXSy)

// 读取当前的注入的method
- (NSSet *)injectsSelects {
    NSMutableSet *injectsSet = [[NSMutableSet alloc] init];
    NSSet *selectors = [DBXRuntimeUtils methodsOfClassFrom:self.class toSuperClass:nil];
    for (NSString *sel in selectors) {
        if (![self.class isExcludeSelector:NSSelectorFromString(sel)]) {
            [injectsSet addObject:sel];
        }
    }
    return injectsSet;
}

// 是否是排除掉的方法
+ (BOOL)isExcludeSelector:(SEL)selector {
    return [[self excludeMethodSet] containsObject:NSStringFromSelector(selector)];
}

// 排除掉的方法名
+ (NSMutableSet *)excludeMethodSet {
    static NSMutableSet *singleSet;
    if (!singleSet) {
        singleSet = [[NSMutableSet alloc] init];
        [singleSet addObject:@"init"];
        [singleSet addObject:@"prepare"];
        [singleSet addObject:@"factory"];
        [singleSet addObject:@"activated"];
        [singleSet addObject:@"activateWithOther"];

    }
    return singleSet;
}

@end
