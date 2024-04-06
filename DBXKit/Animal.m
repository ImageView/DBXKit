//
//  Animal.m
//  DBXKit
//
//  Created by asherluo on 2023/1/27.
//  Copyright © 2023 调包侠. All rights reserved.
//

#import "Animal.h"

@implementation Animal
- (void)run {
    NSLog(@"%s,%@", __func__, self.name);
}

- (void)barking {
    NSLog(@"%s,%@", __func__, self.name);
}
@end
