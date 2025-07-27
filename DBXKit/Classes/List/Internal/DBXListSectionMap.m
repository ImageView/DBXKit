//
//  DBXListSectionMap.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListSectionMap.h"
#import "DBXListSectionController.h"

@interface DBXListSectionMap ()

@property (nonatomic, strong) NSMutableArray *objects;
// 数据跟sectionController的映射
@property(nonatomic, strong) NSMapTable <id, DBXListSectionController *> *objectToSectionControllerMap;
// sbac
@property(nonatomic, strong) NSMapTable <DBXListSectionController *, NSNumber *> *sectionControllerToSectionMap;
@end

@implementation DBXListSectionMap

- (instancetype)init
{
    self = [super init];
    if (self) {
        _objectToSectionControllerMap = [NSMapTable strongToStrongObjectsMapTable];
        _sectionControllerToSectionMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)updateObjects:(NSArray *)objects sectionControllers:(NSArray *)sectionControllers {
    NSAssert(objects.count == sectionControllers.count, @"objects leng != sectionsControllers length");
    self.objects = objects.mutableCopy;
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DBXListSectionController *sectionController = sectionControllers[idx];
        [self.objectToSectionControllerMap setObject:sectionController forKey:obj];
        [self.sectionControllerToSectionMap setObject:@(idx) forKey:sectionController];
    }];
}

- (NSInteger)sectionForSectionController:(DBXListSectionController *)sectionController {
    return [[self.sectionControllerToSectionMap objectForKey:sectionController] integerValue];
}

- (DBXListSectionController *)sectionControllerForObject:(id)object {
    return [self.objectToSectionControllerMap objectForKey:object];
}

- (DBXListSectionController *)sectionControllerForSection:(NSInteger)section {
    return [self.objectToSectionControllerMap objectForKey:[self objectForSection:section]];
}

- (id)objectForSection:(NSInteger)section {
    if (section < 0 || section >= self.objects.count) {
        return nil;
    }
    return self.objects[section];
}

@end
