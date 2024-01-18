//
//  DBXSyringeInject.m
//  DBXKit
//
//  Created by asherluo on 2022/6/8.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeInject.h"
#import "DBXSyringeMethod.h"
#import "DBXSyringeTmpArgument.h"
#import <objc/runtime.h>

@interface DBXSyringeInject ()

// 用来初始化对象
@property(nonatomic, strong) DBXSyringeMethod *outPutInitializer;

/**
 存储初始化时要设置的参数
 key：参数名，value：临时对象DBXSyringeTmpArgument或者具体数据
 */
@property(nonatomic, strong) NSMutableDictionary *injectPropertys;

@end

@implementation DBXSyringeInject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _injectPropertys = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (id)injectWithClass:(Class)clazz configuration:(DBXSyringeInjectBlock)config {
    DBXSyringeInject *inject = [[DBXSyringeInject alloc] init];
    inject.outPutClass = clazz;
    if (config) {
        config(inject);
    }
    return inject;
}

- (void)dealloc {
    
}

// 准备好数据
- (void)dataReady {
    
}

- (void)addPropertyValue:(id)value to:(SEL)selector {
    [self.injectPropertys setValue:value forKey:NSStringFromSelector(selector)];
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)initInstanceWithArgs:(NSArray *)args {
    if (self.outPutInitializer && self.outPutClass) {
        NSInvocation *invocation = [self.outPutInitializer createInvocationWithArgums:args ofClass:self.outPutClass];
        id instanceOutPut = [self.outPutClass alloc];
        [invocation invokeWithTarget:instanceOutPut];
        void *returnValue = NULL;
        [invocation getReturnValue:&returnValue];
        
        // 创建出来的对象
        id returnIntance = (__bridge id)returnValue;
        // 初始化完成后，补充参数值
        for (NSString *propertyName in self.injectPropertys) {
            id obj = self.injectPropertys[propertyName];
            if ([obj isKindOfClass:[DBXSyringeTmpArgument class]]) {
                DBXSyringeTmpArgument *tmpArgum = obj;
                id oneArgum = args[tmpArgum.index];
                [returnIntance setValue:oneArgum forKey:propertyName];
            } else {
                NSObject *instanceObject = returnIntance;
                SEL sel = NSSelectorFromString(propertyName);
                if (classHasProperty(instanceObject.class, propertyName)){
                    [returnIntance setValue:obj forKey:propertyName];
                } else if (classHasMethod(instanceObject.class, sel)) {
                    [instanceObject performSelector:sel withObject:obj];
                }
            }
        }
        
        return returnIntance;
    }
    return nil;
}

// 设置初始化方法
- (void)initOutPutWithSelector:(SEL)selector parames:(void (^)(DBXSyringeMethod *method))paramesBlock {
    DBXSyringeMethod *initMethod = [[DBXSyringeMethod alloc] initWithSelector:selector];
    if (paramesBlock) {
        paramesBlock(initMethod);
    }
    self.outPutInitializer = initMethod;
}

- (DBXSyringeMethod *)outPutInitializer {
    if (!_outPutInitializer) {
        _outPutInitializer = [[DBXSyringeMethod alloc] initWithSelector:@selector(init)];
    }
    return _outPutInitializer;
}


BOOL classHasMethod(Class class, SEL selector) {
    Method method = class_getInstanceMethod(class, selector);
    return (method != NULL);
}

BOOL classHasProperty(Class class, NSString *propertyName) {
    objc_property_t property = class_getProperty(class, propertyName.UTF8String);
    return (property != NULL);
}
@end
