//
//  DBXStubs.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubs.h"
#import "DBXCore.h"
#import <objc/runtime.h>
#import "DBXStubsURLProtocol.h"
#import "DBXCore.h"

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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleDefaultSession];
    });
    return [NSURLProtocol registerClass:DBXStubsURLProtocol.class];
}

+ (void)deactivateStub {
//    if (![DBXCenter functionIsAvailable:DBXFunctionAvailableStubs]) {
//        return;
//    }
    [NSURLProtocol unregisterClass:DBXStubsURLProtocol.class];
}

+ (void)swizzleDefaultSession   {
    Class targetClass = [NSURLSessionConfiguration class];
    
    // 原始类方法选择器
    SEL originalSel = @selector(defaultSessionConfiguration);
    
    // 新类方法选择器
    SEL swizzledSel = @selector(modifiedDefaultSessionConfiguration);
    
    // 获取原始类方法
    Method originalMethod = class_getClassMethod(targetClass, originalSel);
    
    // 获取替换类方法（注意这里要获取类方法）
    Method swizzledMethod = class_getClassMethod(self, swizzledSel);
    
    // 关键：为 NSURLSessionConfiguration 动态添加类方法实现
    BOOL didAddMethod = class_addMethod(object_getClass(targetClass),
                                        swizzledSel,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        // 获取添加后的方法
        Method newMethod = class_getClassMethod(targetClass, swizzledSel);
        // 安全交换
        method_exchangeImplementations(originalMethod, newMethod);
    } else {
        NSLog(@"⚠️ 方法交换失败，请检查方法签名");
    }
}

// 新的类方法实现（必须用类方法！）
+ (NSURLSessionConfiguration *)modifiedDefaultSessionConfiguration {
    // 调用原始实现（现在交换后，这里实际上调用原来的 defaultSessionConfiguration）
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration performSelector:@selector(modifiedDefaultSessionConfiguration)];
    
    Class yourProtocolClass = [DBXStubsURLProtocol class];
    NSArray *existingProtocols = config.protocolClasses;
    
    // 防止重复添加
    if (![existingProtocols containsObject:yourProtocolClass]) {
        NSMutableArray *newProtocols = [NSMutableArray arrayWithArray:existingProtocols ?: @[]];
        [newProtocols insertObject:yourProtocolClass atIndex:0];
        
        // 使用 KVC 安全赋值
        [config setValue:[newProtocols copy] forKey:@"protocolClasses"];
        
        NSLog(@"✅ 协议注入成功: %@", yourProtocolClass);
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
