//
//  DBXRuntimeUtils.m
//  DBXKit
//
//  Created by asherluo on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXRuntimeUtils.h"
#import <objc/runtime.h>

// 工具类
@implementation DBXRuntimeUtils

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

+ (NSArray *)getValidArgumesFromInvocation:(NSInvocation *)invocation {
    NSInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
    if (numberOfArguments <= 2) {
        return nil;
    }
    NSMutableArray *argumentsArray = [NSMutableArray array];
    for (int i = 2; i<numberOfArguments; i++) {
        const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:(NSUInteger)i];
        if (![self validArgumentType:argType]) {
            continue;
        }
        id argu = nil;
        [invocation getArgument:&argu atIndex:i];
        if (strcmp(argType, "@?") == 0) {
            argu = [argu copy];
        }
        [argumentsArray addObject:argu];
    }
    return argumentsArray;
}

+ (NSArray *)getArgumesFromInvocation:(NSInvocation *)invocation {
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
    if (numberOfArguments <= 2) {
        return nil;
    }
    NSMutableArray *argumentsArray = [NSMutableArray array];
    
    for (NSUInteger i = 2; i < numberOfArguments; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        switch (argumentType[0]) {
            case 'c': { // char
                char value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'i': { // int
                int value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 's': { // short
                short value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'l': { // long
                long value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'q': { // long long
                long long value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'C': { // unsigned char
                unsigned char value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'I': { // unsigned int
                unsigned int value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'S': { // unsigned short
                unsigned short value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'L': { // unsigned long
                unsigned long value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'Q': { // unsigned long long
                unsigned long long value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'f': { // float
                float value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'd': { // double
                double value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case 'B': { // BOOL
                BOOL value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:@(value)];
                break;
            }
            case '@': { // id (object)
                __unsafe_unretained id value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:value ? value : [NSNull null]];
                break;
            }
            case ':': { // SEL (selector)
                SEL value;
                [invocation getArgument:&value atIndex:i];
                [argumentsArray addObject:NSStringFromSelector(value)];
                break;
            }
            case '{': { // struct
                // 处理结构体类型
                NSUInteger size;
                NSGetSizeAndAlignment(argumentType, &size, NULL);
                void *buffer = malloc(size);
                [invocation getArgument:buffer atIndex:i];
                NSValue *value = [NSValue valueWithBytes:buffer objCType:argumentType];
                [argumentsArray addObject:value];
                free(buffer);
                break;
            }
            default: {
                // 其他类型，默认一个0
                [argumentsArray addObject:@(0)];
                break;
            }
        }
    }
    
    return [argumentsArray copy];
}

+ (id)getReturnValueFromInvocation:(NSInvocation *)invocation {
    #define WRAP_AND_RETURN(type) \
    do { \
        type val = 0; \
        [invocation getReturnValue:&val]; \
        return @(val); \
    } while (0)

    const char *returnType = invocation.methodSignature.methodReturnType;
    // Skip const type qualifier.
    if (returnType[0] == 'r') {
        returnType++;
    }

    if (strcmp(returnType, @encode(id)) == 0 || strcmp(returnType, @encode(Class)) == 0 || strcmp(returnType, @encode(void (^)(void))) == 0) {
        __autoreleasing id returnObj;
        [invocation getReturnValue:&returnObj];
        return returnObj;
    } else if (strcmp(returnType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(returnType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(returnType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(returnType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(returnType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(returnType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(returnType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(returnType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(returnType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(returnType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(returnType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(returnType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(returnType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(returnType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(returnType, @encode(void)) == 0) {
        // 用以区分是否有返回值
        return DBXUnit.voidUnit;
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(returnType, &valueSize, NULL);

        unsigned char valueBytes[valueSize];
        [invocation getReturnValue:valueBytes];

        return [NSValue valueWithBytes:valueBytes objCType:returnType];
    }

    return nil;

    #undef WRAP_AND_RETURN
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

+ (void)hookClassFrom:(Class)originalClass to:(Class)newClass {
    IMP newIMP = imp_implementationWithBlock(^(id self) {
        return newClass;
    });
    const char *methodType = method_getTypeEncoding(class_getInstanceMethod(originalClass, @selector(class)));
    class_replaceMethod(originalClass, @selector(class), newIMP, methodType);
}

@end


@interface DBXUnit ()
@property(nonatomic, strong) NSString *dbxDescription;
@end
@implementation DBXUnit

+ (instancetype)voidUnit {
    static dispatch_once_t onceToken;
    static DBXUnit *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.dbxDescription = @"(void)";
    });
    return instance;
}

- (NSString *)description {
    return self.dbxDescription ? : [super description];
}
@end
