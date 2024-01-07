//
//  DBXSyringeUtils.m
//  DBXKit
//
//  Created by asherluo on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeUtils.h"
#import <objc/runtime.h>
#import "DBXSyringeFactory.h"
#import "DBXSyringeInterface.h"

// 工具类
@implementation DBXSyringeUtils

+ (NSSet *)methodsOfClassFrom:(_Nonnull Class)clazz toSuperClass:(_Nullable Class)superClazz {
    NSMutableSet *methodSet = [[NSMutableSet alloc] init];
    BOOL next = superClazz;
    do {
        unsigned int count;
        Method *methodList = class_copyMethodList(clazz, &count);
        for (unsigned int i = 0; i < count; i++) {
            Method method = methodList[i];
            [methodSet addObject:NSStringFromSelector(method_getName(method))];
        }
        free(methodList);
        if (next) {
            clazz = class_getSuperclass(clazz);
            next = (clazz && clazz != superClazz);
        }
    } while (next);
    
    return methodSet;
}

+ (BOOL)validArgumentType:(const char *)argType {
    return (strcmp(argType, "@") == 0 || strcmp(argType, "@?") == 0 || strcmp(argType, "#") == 0 );
}

+ (NSArray *)getArgumesFromInvocation:(NSInvocation *)invocation {
    NSInteger argumCount = invocation.methodSignature.numberOfArguments;
    if (argumCount <= 2) {
        return nil;
    }
    NSMutableArray *argumes = [NSMutableArray array];
    for (int i = 2; i<argumCount; i++) {
        const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:(NSUInteger)i];
        if (![self validArgumentType:argType]) {
            continue;
        }
        id argu = nil;
        [invocation getArgument:&argu atIndex:i];
        if (strcmp(argType, "@?") == 0) {
            argu = [argu copy];
        }
        [argumes addObject:argu];
    }
    return argumes;
}

+ (NSUInteger)argumentCountInSelector:(SEL)selector
{
    NSString *selStr = NSStringFromSelector(selector);
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < selStr.length; i++) {
        if ([selStr characterAtIndex:i] == ':') {
            count++;
        }
    }
    return count;
}

+ (NSMethodSignature *)defaultSignatureForSelector:(SEL)selector {
    NSUInteger argCnt = [self argumentCountInSelector:selector];
    NSMutableString *signStr = [[NSMutableString alloc] initWithCapacity:argCnt + 3];
    [signStr appendFormat:@"%s%s%s", @encode(id), @encode(id), @encode(SEL)];
    for (NSUInteger i = 0; i < argCnt; i++) {
        [signStr appendString:[NSString stringWithCString:@encode(id) encoding:NSASCIIStringEncoding]];
    }
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:[signStr cStringUsingEncoding:NSASCIIStringEncoding]];

    return signature;
}

@end
