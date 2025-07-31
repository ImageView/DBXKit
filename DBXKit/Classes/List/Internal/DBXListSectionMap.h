//
//  DBXListSectionMap.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXListSectionController;
@interface DBXListSectionMap : NSObject

// 对象组
@property(nonatomic, strong, readonly) NSArray *objects;

// 重置数据
- (void)reset;

// 更新数据组和对应的sectionControllers
- (void)updateObjects:(NSArray *)objects sectionControllers:(NSArray *)sectionControllers;

// 获取sectionController对应的section
- (NSInteger)sectionForSectionController:(DBXListSectionController *)sectionController;

// 获取object对应的sectionCtroller
- (DBXListSectionController *)sectionControllerForObject:(id)object;

// 获取对应seciton的sectionController
- (DBXListSectionController *)sectionControllerForSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
