//
//  DBXSyringeFactory.m
//  DBXKit
//
//  Created by 调包侠 on 2022/6/7.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeFactory.h"
#import "DBXSyringeInject.h"
#import "DBXSyringeInterface.h"
#import "DBXRuntimeUtils.h"

@interface DBXSyringeFactory ()

//@property(nonatomic, strong) NSLock *lock;
@end

// 用来生成指定类的的工厂
@implementation DBXSyringeFactory

- (void)dealloc {
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (id)createInstanceWithSelector:(SEL)selector argumes:(NSArray *)argumes {
    DBXSyringeInject *inject = [self.interface injectOfSelector:selector];
    NSObject *outPut = [inject initInstanceWithArgs:argumes];
    return outPut;
}

#pragma mark - Runtime Forward
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *sign = [self.interface methodSignatureForSelector:selector];
    return sign;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
//    [self.lock lock];
    @synchronized (self) {
        NSArray *argumes = [DBXRuntimeUtils getValidArgumesFromInvocation:invocation];
        id outPut = [self createInstanceWithSelector:invocation.selector argumes:argumes];
        [invocation setReturnValue:&outPut];
    }
//    [self.lock unlock];
}

@end
