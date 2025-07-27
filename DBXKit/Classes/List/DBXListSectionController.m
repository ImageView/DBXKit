//
//  DBXListSectionController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListSectionController.h"
#import "DBXCore.h"

@implementation DBXListSectionController

- (NSInteger)numberOfItems {
    return 1;
}

- (UICollectionViewCell *)cellForItemAtItem:(NSInteger)item {
    return [self dequeueReusableCellOfClass:[UICollectionViewCell class] atItem:item];
}

- (UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass atItem:(NSInteger)item {
    DBXpLog(@"index = %d", (int)item);
    return [self.context dequeueReusableCellOfClass:cellClass forSectionController:self atItem:item];
}

@end
