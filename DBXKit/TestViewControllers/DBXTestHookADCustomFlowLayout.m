//
//  DBXTestHookADCustomFlowLayout.m
//  DBXKit
//
//  Created by 调包侠 on 2025/8/2.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXTestHookADCustomFlowLayout.h"

@implementation DBXTestHookADCustomFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    // 初始化布局属性等
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *allAttributes = [attributes mutableCopy];
    
    for (UICollectionViewLayoutAttributes *attr in attributes) {
        if (attr.representedElementKind == UICollectionElementKindSectionHeader) {
            attr.frame = CGRectMake(attr.frame.origin.x, attr.frame.origin.y, 98, 80);
        }
    }
    return allAttributes;
}

@end
