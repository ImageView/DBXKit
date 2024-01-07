//
//  DBXSyringeMethod.m
//  DBXKit
//
//  Created by asherluo on 2022/6/8.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeMethod.h"
#import "DBXSyringeTmpArgument.h"

@interface DBXSyringeMethod ()

// 存储参数
@property(nonatomic, strong) NSMutableArray *parameters;

@end

@implementation DBXSyringeMethod

- (instancetype)initWithSelector:(SEL)selector
{
    self = [super init];
    if (self) {
        _selector = selector;
        _parameters = [NSMutableArray array];
    }
    return self;
}

- (id)init
{
    return [self initWithSelector:nil];
}

- (NSInvocation *)createInvocationWithArgums:(NSArray *)argums ofClass:(nonnull Class)clazz{
    BOOL isInstanceMethod = YES;
    if ([clazz respondsToSelector:self.selector] && ![clazz instancesRespondToSelector:self.selector]) {
        isInstanceMethod = NO;
    }
    NSMethodSignature *signa = isInstanceMethod ? [clazz instanceMethodSignatureForSelector:self.selector] : [clazz methodSignatureForSelector:self.selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signa];
    [invocation retainArguments];
    [invocation setSelector:self.selector];

    // 将存在参数里面的临时参数替换为真正参数
    [self.parameters enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger index = idx + 2;
        if (index >= signa.numberOfArguments) {
            return;
        }
        if ([obj isKindOfClass:[DBXSyringeTmpArgument class]]) {
            DBXSyringeTmpArgument *tmpArgum = obj;
            id oneArgum = argums[tmpArgum.index];
            [invocation setArgument:&oneArgum atIndex:index];
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            // 数字可能要转化为基本类型，需要在这里特别处理
            [self setInvacation:invocation number:obj atIndex:index];
        } else {
            [invocation setArgument:&obj atIndex:index];
        }
    }];

    return invocation;
}

- (void)addParameter:(id)parameter {
    [self.parameters addObject:parameter];
}

- (void)setInvacation:(NSInvocation *)invocation number:(id)obj atIndex:(NSInteger)index {
    const char *argType = [[invocation methodSignature] getArgumentTypeAtIndex:index];
    // 数字可能要转化为基本类型，需要在这里特别处理
    if (strcmp(argType, @encode(id)) == 0) {
        [invocation setArgument:&obj atIndex:index];
    } else if (strcmp(argType, @encode(int)) == 0) {
        int tmpNum = [obj intValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(float)) == 0) {
        float tmpNum = [obj floatValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(double)) == 0) {
        double tmpNum = [obj doubleValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(long)) == 0) {
        long tmpNum = [obj longValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(long long)) == 0) {
        long long tmpNum = [obj longLongValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        unsigned long long tmpNum = [obj unsignedLongLongValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        unsigned int tmpNum = [obj unsignedIntValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(bool)) == 0) {
        bool tmpNum = [obj boolValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(short)) == 0) {
        short tmpNum = [obj shortValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(char)) == 0) {
        char tmpNum = [obj charValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        unsigned char tmpNum = [obj unsignedCharValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        unsigned short tmpNum = [obj unsignedShortValue];
        [invocation setArgument:&tmpNum atIndex:index];
    } else {
        [NSException raise:@"不支持的Number类型" format:@"'%s' 不支持", argType];
    }
}

@end
