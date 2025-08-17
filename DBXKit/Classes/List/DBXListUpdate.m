//
//  DBXListUpdate.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/17.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListUpdate.h"

@implementation DBXListUpdate

- (instancetype)init
{
    self = [super init];
    if (self) {
        _updateConfig = (DBXListUpdateConfig){
            .enable = YES,
            .minInterval = 50,
            .maxInterval = 500
        };
    }
    return self;
}



@end
