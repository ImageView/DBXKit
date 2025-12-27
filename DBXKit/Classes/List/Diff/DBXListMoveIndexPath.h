//
//  DBXListMoveIndexPath.h
//  DBXKit
//
//  Created by 调包侠 on 2025/11/21.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXListMoveIndexPath : NSObject

@property (nonatomic, strong, readonly) NSIndexPath *from;
@property (nonatomic, strong, readonly) NSIndexPath *to;

@end

NS_ASSUME_NONNULL_END
