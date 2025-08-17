//
//  DBXListTransitionData.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/17.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListTransitionData.h"

@implementation DBXListTransitionData

- (instancetype)initWithFromObjects:(NSArray *)fromObjects toObjects:(NSArray *)toObjects sectionControllers:(NSArray <DBXListSectionController *> *)sectionControllers
{
    self = [super init];
    if (self) {
        _fromObjects = fromObjects;
        _toObjects = toObjects;
        _sectionContollers = sectionControllers;
    }
    return self;
}

@end
