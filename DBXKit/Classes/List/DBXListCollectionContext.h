//
//  DBXListCollectionContext.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListCollectionContext_h
#define DBXListCollectionContext_h

#import <UIKit/UIKit.h>

@class DBXListSectionController;
@protocol DBXListCollectionContext <NSObject>

- (UICollectionViewCell *)dequeueReusableCellOfClass:(Class)cellClass forSectionController:(DBXListSectionController *)sectionController atItem:(NSInteger)item;

- (__kindof UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind
                                                         forSectionController:(DBXListSectionController *)sectionController
                                                                    viewClass:(Class)viewClass
                                                                       atItem:(NSInteger)item;
@end

#endif /* DBXListCollectionContext_h */
