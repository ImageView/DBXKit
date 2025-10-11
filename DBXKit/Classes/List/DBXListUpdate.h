//
//  DBXListUpdate.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/17.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBXListUpdatingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    BOOL enable;        // 默认开启
    NSTimeInterval minInterval;     // 更新最短时间
    NSTimeInterval maxInterval;     // 更新最大时间
} DBXListUpdateConfig;

@class DBXListTransitionData;


// list更新类
@interface DBXListUpdate : NSObject

// 更新的配置
@property(nonatomic, assign) DBXListUpdateConfig updateConfig;

- (void)performUpdateWithCollectionViewBlock:(DBXListUpdateCollectionViewBlock)collectionViewBlock
                         transitionDataBlock:(DBXListUpdateTransitionDataBlock)transitionDataBlock
                              applyDataBlock:(DBXListUpdateApplyTransitionDataBlock)applyBlock
                                  completion:(DBXListUpdateCompletion)completion;

@end

NS_ASSUME_NONNULL_END
