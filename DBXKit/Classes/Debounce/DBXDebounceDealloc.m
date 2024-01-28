//
//  DBXDebounceDealloc.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/27.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXDebounceDealloc.h"
//#import <objc/runtime.h>
//#import <objc/message.h>
#import <pthread.h>

@interface DBXDebounceDealloc ()

@property(nonatomic, assign) pthread_mutex_t invokeLock;

@end

@implementation DBXDebounceDealloc

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_invokeLock, &attr);
    }
    return self;
}

- (void)lock {
    pthread_mutex_lock(&_invokeLock);
}

- (void)unlock {
    pthread_mutex_unlock(&_invokeLock);
}

@end
