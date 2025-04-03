//
//  DBXStubs.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubs.h"
#import "DBXCore.h"
#import "DBXStubsURLProtocol.h"

NSString* __nullable DBXPathForFile(NSString* fileName, Class inBundleForClass) {
    NSBundle* bundle = [NSBundle bundleForClass:inBundleForClass];
    return [bundle pathForResource:[fileName stringByDeletingPathExtension]
                            ofType:[fileName pathExtension]];
}

#pragma mark - DBXStubsRule类
/// 一个截取的规则
@interface DBXStubsRule ()
// 过滤block
@property(nonatomic, copy) StubConditionBlock conditionBlock;

@end
@implementation DBXStubsRule
- (NSString*)description {
    return [NSString stringWithFormat:@"<%@ %p : %@>", self.class, self, self.name];
}
@end

#pragma mark - DBXStubs类
@interface DBXStubs ()
@property(nonatomic, copy) NSMutableArray* stubRules;   // 存储规则]
@property(nonatomic, strong) NSLock *listLock;
@end

@implementation DBXStubs

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXStubs *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (BOOL)activateStub {
    if (![DBXCenter functionIsAvailable:DBXFunctionAvailableStubs]) {
        return NO;
    }
    return [NSURLProtocol registerClass:DBXStubsURLProtocol.class];
}

+ (void)deactivateStub {
//    if (![DBXCenter functionIsAvailable:DBXFunctionAvailableStubs]) {
//        return;
//    }
    [NSURLProtocol unregisterClass:DBXStubsURLProtocol.class];
}

+ (DBXStubsRule *)stubMatching:(StubConditionBlock)condition
                 responseWith:(StubsResponseBlock)response {
    DBXStubsRule *stubRule = [[DBXStubsRule alloc] init];
    stubRule.conditionBlock = condition;
    stubRule.responseBlock = response;
    [DBXStubs.sharedInstance addStubRule:stubRule];
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

- (void)addStubRule:(DBXStubsRule *)stubRule {
    [_listLock lock];
    [self.stubRules addObject:stubRule];
    [_listLock unlock];
}

+ (void)removeStubRule:(DBXStubsRule *)stubRule {
    [DBXStubs.sharedInstance.listLock lock];
    [DBXStubs.sharedInstance.stubRules removeObject:stubRule];
    [DBXStubs.sharedInstance.listLock unlock];
}

+ (DBXStubsRule *)findMatchStubForRequest:(NSURLRequest *)request {
    DBXStubsRule *findRule = nil;
    for (DBXStubsRule *rule in DBXStubs.sharedInstance.stubRules) {
        if (rule.conditionBlock(request)) {
            findRule = rule;
            break;
        }
    }
    return findRule;
}

@end
