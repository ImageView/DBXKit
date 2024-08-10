//
//  DBXSyringeInterface.m
//  DBXKit
//
//  Created by asherluo on 2022/6/7.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeInterface.h"
#import "DBXSyringeFactory.h"
#import "DBXSyringeInterface+DBXSy.h"
#import "DBXSyringeTmpArgument.h"
#import "DBXRuntimeUtils.h"

@interface DBXSyringeInterface ()

// 维持内存

// 工厂
@property(nonatomic, weak) DBXSyringeFactory *factory;

/**
 存储所有inject的对象
 key：inject的sel，value：inject实例
 */
@property(nonatomic, strong) NSMutableDictionary *injectInstanceCache;

@end

@implementation DBXSyringeInterface

- (instancetype)init
{
    self = [super init];
    if (self) {
        _injectInstanceCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    
}

+ (instancetype)activatedInterface {
    id instance = [[self alloc] init];
    return [instance activated];
}

- (instancetype)activated {
    if (self.factory) {
        return (id)self.factory;
    } else {
        return [self activateWithOther];
    }
}

- (id)injectOfSelector:(SEL)selector {
    return self.injectInstanceCache[NSStringFromSelector(selector)];
}

// 准备数据
- (void)prepare {
    NSSet *injectsSels = [self injectsSelects];
    [injectsSels enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *selStr = obj;
        SEL sel = NSSelectorFromString(selStr);
        if (!sel) {
            return;
        }
        if (![self.injectInstanceCache valueForKey:selStr]) {
            id result = nil;
            NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:sel];
            NSInteger argumCount = signature.numberOfArguments;
            if (argumCount > 2) {
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                invocation.target = self;
                invocation.selector = sel;
                [invocation retainArguments];
                
                // invocation 有2个隐藏参数，所以 argument 从2开始
                for (NSUInteger i = 0; i < argumCount - 2; i++) {
                    const char *argType = [signature getArgumentTypeAtIndex:i + 2];
                    // object / block / metaClass
                    if ([DBXRuntimeUtils validArgumentType:argType]) {
                        // 创建临时参数
                        DBXSyringeTmpArgument *tmpArgument = [[DBXSyringeTmpArgument alloc] initWithIndex:i];
                        [invocation setArgument:&tmpArgument atIndex:i + 2];
                    } else {
                        NSAssert(NO, @"%@参数需要是对象类型",selStr);
                    }
                }
                
                [invocation invoke];
                
                void *returnVal;
                [invocation getReturnValue:&returnVal];
                result = (__bridge id)returnVal;
            } else {
                // 无参数的直接调
                id(*impl)(id, SEL) = (id(*)(id, SEL))[((NSObject *)self) methodForSelector:sel];
                result = impl(self, sel);
            }
            if ([result respondsToSelector:@selector(key)]) {
                [result setValue:selStr forKey:@"key"];
            }
            self.injectInstanceCache[selStr] = result;
        }
    }];
}

- (instancetype)activateWithOther {
    DBXSyringeFactory *factory = [[DBXSyringeFactory alloc] init];
    factory.interface = self;
    self.factory = factory;
    [self prepare];
    return (id)self.factory;
}

@end
