//
//  DBXStubRule.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/25.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXStubsResponse;

typedef BOOL(^StubConditionBlock)(NSURLRequest *requeset);
typedef DBXStubsResponse* _Nonnull (^StubsResponseBlock)(NSURLRequest* request);

/// 一个截取的规则
@interface DBXStubRule : NSObject

// 自定义名字
@property(nonatomic, copy, nullable) NSString *name;

@end

NS_ASSUME_NONNULL_END
