//
//  DBXListTransitionData.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/17.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXListSectionController;
// 记录数据变更的数据
@interface DBXListTransitionData : NSObject

@property(nonatomic, copy, readonly) NSArray *fromObjects;
@property(nonatomic, copy, readonly) NSArray *toObjects;
@property(nonatomic, copy, readonly) NSArray <DBXListSectionController *> *sectionContollers;

- (instancetype)initWithFromObjects:(NSArray *)fromObjects toObjects:(NSArray *)toObjects sectionControllers:(NSArray <DBXListSectionController *> *)sectionControllers;

@end

NS_ASSUME_NONNULL_END
