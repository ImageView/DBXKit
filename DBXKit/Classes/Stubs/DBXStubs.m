//
//  DBXStubs.m
//  DBXKit
//
//  Created by 调包侠 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubs.h"
#import "DBXCore.h"
#import <objc/runtime.h>
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
@property(nonatomic, copy) NSMutableArray* stubRules;   // 存储规则
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
    [self swizzleDefaultSession];
    return [NSURLProtocol registerClass:DBXStubsURLProtocol.class];
}

+ (void)deactivateStub {
    [self reSwizzleDefaultSession];
    [NSURLProtocol unregisterClass:DBXStubsURLProtocol.class];
}

+ (void)swizzleDefaultSession   {
    Class metaClass = object_getClass([NSURLSessionConfiguration class]);
    Method originalMethod = class_getClassMethod([NSURLSessionConfiguration class], @selector(defaultSessionConfiguration));
    
    IMP originalMethodIMP = method_getImplementation(originalMethod);
    if (originalMethodIMP != (IMP)dbx_DefaultSessionConfiguration) {
        const char *typeEncoding = method_getTypeEncoding(originalMethod);
        IMP originalIMP = class_replaceMethod(metaClass, @selector(defaultSessionConfiguration), (IMP)dbx_DefaultSessionConfiguration, typeEncoding);
        if (originalIMP) {
            class_addMethod(metaClass, NSSelectorFromString(@"__dbx_orignalDefaultSessionConfiguration"), originalIMP, typeEncoding);
        }
    }
}

+ (void)reSwizzleDefaultSession {
    Class metaClass = object_getClass([NSURLSessionConfiguration class]);
    Method targetMethod = class_getInstanceMethod(metaClass, @selector(defaultSessionConfiguration));
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (targetMethodIMP == (IMP)dbx_DefaultSessionConfiguration) {
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        Method originalMethod = class_getInstanceMethod(metaClass, NSSelectorFromString(@"__dbx_orignalDefaultSessionConfiguration"));
        IMP originalIMP = method_getImplementation(originalMethod);
        class_replaceMethod(metaClass, @selector(defaultSessionConfiguration), originalIMP, typeEncoding);
    }
}

static NSURLSessionConfiguration * dbx_DefaultSessionConfiguration(void) {
    SEL originalSelector = NSSelectorFromString(@"__dbx_orignalDefaultSessionConfiguration");
    __unsafe_unretained NSURLSessionConfiguration *config;
    if ([NSURLSessionConfiguration respondsToSelector:originalSelector]) {
        // 使用 NSInvocation 处理返回值（适用于非 void 返回类型）
        NSMethodSignature *signature = [NSURLSessionConfiguration methodSignatureForSelector:originalSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:originalSelector];
        [invocation invokeWithTarget:[NSURLSessionConfiguration class]];
        
        // 获取返回值（假设返回类型为 NSURLSessionConfiguration*）
        [invocation getReturnValue:&config];
    }
    
    Class stubsProtocolClass = [DBXStubsURLProtocol class];
    NSArray *existingProtocols = config.protocolClasses;
    
    // 避免重复添加
    if (![existingProtocols containsObject:stubsProtocolClass]) {
        NSMutableArray *newProtocols = [NSMutableArray arrayWithArray:existingProtocols ?: @[]];
        [newProtocols insertObject:stubsProtocolClass atIndex:0];
        // 使用 KVC 安全赋值
        [config setValue:[newProtocols copy] forKey:@"protocolClasses"];
        DBXpLog(@"✅ 协议注入成功: %@", stubsProtocolClass);
    }
    
    return config;
}

+ (DBXStubsRule *)stubMatching:(StubConditionBlock)condition responseWith:(StubsResponseBlock)response {
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
