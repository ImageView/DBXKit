//
//  NSObject+PropertyObserver.m
//  DBXKit
//
//  Created by 罗俊宇 on 2023/10/10.
//  Copyright © 2023 DBX. All rights reserved.
//

#import "NSObject+PropertyObserver.h"
#import <objc/runtime.h>

@implementation NSObject (PropertyObserver)

static char kAssociatedObjectKey_CallBackMaps;
- (NSMutableDictionary<id, id> *)dbx_callBackMaps {
    NSMutableDictionary<id, id> *dict = objc_getAssociatedObject(self, &kAssociatedObjectKey_CallBackMaps);
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_CallBackMaps, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)dbx_addObserverForKeyPath:(NSString *)keyPath valueChange:(void (^)(id _Nullable value))changedCallBack {
    if (!keyPath || !changedCallBack) {
        return;
    }
    [self.dbx_callBackMaps setObject:changedCallBack forKey:keyPath];
    [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dbx_removeObserverForKeyPath:(NSString *)keyPath {
    [self.dbx_callBackMaps removeObjectForKey:keyPath];
    [self removeObserver:self forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    void (^changedCallBack)(id value) = [self.dbx_callBackMaps objectForKey:keyPath];
    if (changedCallBack) {
        changedCallBack(change[@"new"]);
    }
}

@end
