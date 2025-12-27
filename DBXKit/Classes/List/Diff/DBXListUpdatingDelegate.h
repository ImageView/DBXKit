//
//  DBXListUpdatingDelegate.h
//  DBXKit
//
//  Created by 调包侠 on 2025/10/11.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListUpdatingDelegate_h
#define DBXListUpdatingDelegate_h
#import <UIKit/UIKit.h>
#import "DBXListTransitionData.h"

typedef UICollectionView *_Nullable(^DBXListUpdateCollectionViewBlock)(void);
typedef DBXListTransitionData *_Nullable(^DBXListUpdateTransitionDataBlock)(void);
typedef void (^DBXListUpdateApplyTransitionDataBlock)(DBXListTransitionData * _Nullable data);
typedef void(^DBXListUpdateCompletion)(BOOL finish);

#endif /* DBXListUpdatingDelegate_h */
