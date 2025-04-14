//
//  DBXStubs.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXStubsResponse.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif
NSString * _Nullable DBXPathForFile(NSString * _Nonnull fileName, Class _Nonnull inBundleForClass);
#ifdef __cplusplus
}
#endif

@class DBXStubsResponse;

typedef BOOL(^StubConditionBlock)(NSURLRequest *request);
typedef DBXStubsResponse* _Nonnull (^StubsResponseBlock)(NSURLRequest* request);

#pragma mark - 截取规则的类
@interface DBXStubsRule : NSObject
// 自定义名字
@property(nonatomic, copy, nullable) NSString *name;
// 返回值block
@property(nonatomic, copy) StubsResponseBlock responseBlock;

@end


#pragma mark - 核心类类
@interface DBXStubs : NSObject

+ (BOOL)activateStub;

+ (void)deactivateStub;

+ (DBXStubsRule *)stubMatching:(StubConditionBlock)condition
                  responseWith:(StubsResponseBlock)response;
// 移除规则
+ (void)removeStubRule:(DBXStubsRule *)stubRule;

+ (DBXStubsRule *)findMatchStubForRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
