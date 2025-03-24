//
//  DBXStubTask.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/25.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubRule.h"

@interface DBXStubRule ()
// 过滤block
@property(nonatomic, copy) StubConditionBlock conditionBlock;
// 返回值block
@property(nonatomic, copy) StubsResponseBlock responseBlock;
@end

@implementation DBXStubRule

@end
