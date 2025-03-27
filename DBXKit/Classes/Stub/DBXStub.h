//
//  DBXStub.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXStubsResponse;

typedef BOOL(^StubConditionBlock)(NSURLRequest *requeset);
typedef DBXStubsResponse* _Nonnull (^StubsResponseBlock)(NSURLRequest* request);

#pragma mark - 截取规则的类
@interface DBXStubRule : NSObject
// 自定义名字
@property(nonatomic, copy, nullable) NSString *name;
@end

#pragma mark - 核心类类
@interface DBXStub : NSObject

+ (DBXStubRule *)stubMatching:(StubConditionBlock)condition
                          responseWith:(StubsResponseBlock)response;
// 移除规则
+ (void)removeStubRule:(DBXStubRule *)stubRule;

+ (DBXStubRule *)findMatchStubForRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
