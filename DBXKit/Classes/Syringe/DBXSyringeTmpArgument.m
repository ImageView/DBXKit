//
//  DBXSyringeTmpArgument.m
//  DBXKit
//
//  Created by 调包侠 on 2022/9/15.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeTmpArgument.h"

// 临时参数
@implementation DBXSyringeTmpArgument

- (instancetype)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _index = index;
    }
    return self;
}

@end
