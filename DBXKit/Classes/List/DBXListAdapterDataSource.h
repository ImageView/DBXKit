//
//  DBXListAdapterDataSource.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/26.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListAdapterDataSource_h
#define DBXListAdapterDataSource_h

#import <UIKit/UIKit.h>

@class DBXListAdapter;
@class DBXListSectionController;
@protocol DBXListAdapterDataSource <NSObject>

@required
- (NSArray *)objectsForListAdapter:(DBXListAdapter *)adapter;

- (DBXListSectionController *)listAdapter:(DBXListAdapter *)adapter sectionControllerForObject:(id)object;

@end

#endif /* DBXListAdapterDataSource_h */
