//
//  DBXListUpdate.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/17.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    BOOL enable;        // 默认开启
    NSTimeInterval minInterval;     // 更新最短时间
    NSTimeInterval maxInterval;     // 更新最大时间
} DBXListUpdateConfig;

typedef UICollectionView *_Nullable(^DBXListUpdateCollectionViewBlock)(void);


@interface DBXListUpdate : NSObject

@property(nonatomic, assign) DBXListUpdateConfig updateConfig;

- (void)performUpdateWithCollectionViewBlock:(DBXListUpdateCollectionViewBlock)collectionViewBlock;

@end

NS_ASSUME_NONNULL_END
