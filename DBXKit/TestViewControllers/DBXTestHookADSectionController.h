//
//  DBXTestHookADSectionController.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListSectionController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DBXTestHookADSectionControllerDelegate <NSObject>

- (void)sectionColtrollerReload;
- (void)deleteObjectItem:(NSInteger)item;
- (void)insertObjectToItem:(NSInteger)item;
- (void)updateObject:(NSString *)obj atItem:(NSInteger)item;
@end

@interface DBXTestHookADSectionController : DBXListSectionController<DBXTestHookADSectionControllerDelegate>

@property(nonatomic, weak) id <DBXTestHookADSectionControllerDelegate> delegate;

@end



@interface DBXTestADSectionController : DBXListSectionController<DBXListSupplementaryViewSource>

@end
NS_ASSUME_NONNULL_END
