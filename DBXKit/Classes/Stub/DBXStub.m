//
//  DBXStub.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStub.h"

#pragma mark - DBXStubRule类
/// 一个截取的规则
@interface DBXStubRule ()
// 过滤block
@property(nonatomic, copy) StubConditionBlock conditionBlock;
// 返回值block
@property(nonatomic, copy) StubsResponseBlock responseBlock;
@end
@implementation DBXStubRule
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@ %p : %@>", self.class, self, self.name];
}
@end

#pragma mark - DBXStub类
@interface DBXStub ()
@property(nonatomic, copy) NSMutableArray* stubRules;   // 存储规则]
@property(nonatomic, strong) NSLock *listLock;
@end

@implementation DBXStub

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXStub *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (DBXStubRule *)stubMatching:(StubConditionBlock)condition
                 responseWith:(StubsResponseBlock)response {
    DBXStubRule *stubRule = [[DBXStubRule alloc] init];
    stubRule.conditionBlock = condition;
    stubRule.responseBlock = response;
    [DBXStub.sharedInstance addStubRule:stubRule];
    return stubRule;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stubRules = [NSMutableArray array];
        _listLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)addStubRule:(DBXStubRule *)stubRule {
    [_listLock lock];
    [self.stubRules addObject:stubRule];
    [_listLock unlock];
}

+ (void)removeStubRule:(DBXStubRule *)stubRule {
    [DBXStub.sharedInstance.listLock lock];
    [DBXStub.sharedInstance.stubRules removeObject:stubRule];
    [DBXStub.sharedInstance.listLock unlock];
}

+ (DBXStubRule *)findMatchStubForRequest:(NSURLRequest *)request {
    DBXStubRule *findRule = nil;
    for (DBXStubRule *rule in DBXStub.sharedInstance.stubRules) {
        if (rule.conditionBlock(request)) {
            findRule = rule;
            break;
        }
    }
    return findRule;
}

@end
