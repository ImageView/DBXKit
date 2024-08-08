//
//  DBXTrackTarget.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

// 追踪的目标
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXTrackTarget : NSObject

// 跟踪的真实目标
@property(nonatomic, weak) id target;

@end

NS_ASSUME_NONNULL_END
