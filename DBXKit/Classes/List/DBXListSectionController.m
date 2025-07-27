//
//  DBXListSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListSectionController.h"

@implementation DBXListSectionController

- (NSInteger)numberOfItems {
    return 1;
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    return [self.context dequeueReusableCellOfClass:[UICollectionViewCell class] forSectionController:self atIndex:index];
}

@end
