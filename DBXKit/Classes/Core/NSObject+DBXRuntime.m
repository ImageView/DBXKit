//
//  NSObject+DBXRuntime.m
//  DBXKit
//
//  Created by 罗俊宇 on 2022/7/10.
//  Copyright © 2022 DBX. All rights reserved.
//

#import "NSObject+DBXRuntime.h"
#import <objc/runtime.h>

// 方法交换
@implementation NSObject (DBXRuntime)

+ (BOOL)dbx_swizzleMethod:(SEL)_originSelector newMethod:(SEL)_newSelector error:(NSError **)error {
    
    Method oriMethod = class_getInstanceMethod(self, _originSelector);
    Method newMethod = class_getInstanceMethod(self, _newSelector);
    if (!newMethod) {
        return NO;
    }
    
    BOOL isAddedMethod = class_addMethod(self, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        // 如果 class_addMethod 成功了，说明之前 fromClass 里并不存在 originSelector，所以要用一个空的方法代替它，以避免 class_replaceMethod 后，后续 toClass 的这个方法被调用时可能会 crash
        IMP oriMethodIMP = method_getImplementation(oriMethod) ?: imp_implementationWithBlock(^(id selfObject) {});
        const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
        class_replaceMethod(self, _newSelector, oriMethodIMP, oriMethodTypeEncoding);
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
    return YES;
}
@end
