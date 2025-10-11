//
//  DBXListUpdatingDelegate.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/10/11.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListUpdatingDelegate_h
#define DBXListUpdatingDelegate_h
#import <UIKit/UIKit.h>

typedef UICollectionView *_Nullable(^DBXListUpdateCollectionViewBlock)(void);
typedef DBXListTransitionData *_Nullable(^DBXListUpdateTransitionDataBlock)(void);
typedef void (^DBXListUpdateApplyTransitionDataBlock)(DBXListTransitionData *);
typedef void(^DBXListUpdateCompletion)(BOOL finish);

#endif /* DBXListUpdatingDelegate_h */
