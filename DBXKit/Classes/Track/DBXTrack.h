//
//  DBXTrack.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXTrackTarget.h"

NS_ASSUME_NONNULL_BEGIN


@interface DBXTrack : NSObject

//+ (BOOL)dbx_trackTarget:(DBXTrackTarget *)targetModel methodCall:(void (^)(NSInvocation *invocation))call;

+ (void)dbx_trackTarget:(id)target
                 condition:(ConditionBlock)conditionBlock
                    before:(WhenInvocateBlock)beforeBlock
                     after:(WhenInvocateBlock)afterBlock;
@end

NS_ASSUME_NONNULL_END
