//
//  DBXTrack.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXTrack.h"
#import <objc/runtime.h>
#import "DBXTrackTarget.h"
#import <objc/message.h>

static NSString *const DBXTrackForwardInvocationSelectorName = @"__dbx_track_forwardInvocation:";
static NSString *const DBXTrackSubclassPrefix = @"_DBXTrackDebounce_";

@interface DBXTrack ()
// 记录被修改了impl的类
@property (class, readonly, nonatomic) NSMutableSet<Class> *classHooked;

@end

@implementation DBXTrack

+ (BOOL)dbx_trackTarget:(DBXTrackTarget *)targetModel methodCall:(void (^)(NSInvocation *invocation))call {
    Class isaClass = object_getClass(targetModel.target);
    Class ocClass = [targetModel.target class];
    NSString *isaClassName= NSStringFromClass(isaClass);
    Class cls;
    // 动态创建一个子类指向原本的cls，避免影响原cls
    if ([isaClassName containsString:DBXTrackSubclassPrefix]) {
        cls = ocClass;
    } else if (object_isClass(targetModel.target)) {
        cls = targetModel.target;
    } else if (ocClass != isaClass) {
        cls = ocClass;
    } else {
        // 创建个动态类，并指向它
        const char *subClassName = [DBXTrackSubclassPrefix stringByAppendingString:isaClassName].UTF8String;
        Class subClass = objc_getClass(subClassName);
        if (!subClass) {
            subClass = objc_allocateClassPair(ocClass, subClassName, 0);
            if (!subClass) {
                return NO;
            }
//            [DBXDebounce hookClassFrom:subClass to:ocClass];
//            [DBXDebounce hookClassFrom:object_getClass(subClass) to:ocClass];
            objc_registerClassPair(subClass);
        }
        object_setClass(targetModel.target, subClass);
        cls = subClass;
    }
    
    for (Class clsHooked in self.classHooked) {
        // 检查其子类是否被hook了
        if (clsHooked != cls && [clsHooked isSubclassOfClass:cls]) {
            return NO;
        }
    }
    IMP targetOriginalForwardImp = class_getMethodImplementation(cls, @selector(forwardInvocation:));
    if (targetOriginalForwardImp != (IMP)dbx_track_forwardInvocation) {
        IMP originalIMP = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)dbx_track_forwardInvocation, "v@:@");
        if (originalIMP) {
            class_addMethod(cls, NSSelectorFromString(DBXTrackForwardInvocationSelectorName), originalIMP, "v@:@");
        }
    }
    
    unsigned int outCount;
    Method *methods = class_copyMethodList(cls, &outCount);
    
    for (int i = 0; i < outCount; i ++) {
        Method tempMethod = *(methods + i);
        SEL selector = method_getName(tempMethod);
        char *returnType = method_copyReturnType(tempMethod);
        
        dbx_track_replaceMethod(cls, selector, returnType);
        free(returnType);
    }
    return YES;
}

BOOL dbx_track_replaceMethod(Class cls, SEL originSelector, char *returnType) {
    Method targetMethod = class_getInstanceMethod(cls, originSelector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (targetMethodIMP != _objc_msgForward) {
//        const char *typeEncoding = method_getTypeEncoding(targetMethod);
//
//        // 给cls添加一个新方法aliasSelector，实现为rule的selector
//        Method aliMethod = class_getInstanceMethod(cls, rule.aliasSelector);
//        Method superAliMethod = class_getInstanceMethod(class_getSuperclass(cls), rule.aliasSelector);
//        if (![cls instanceMethodForSelector:rule.aliasSelector] || aliMethod == superAliMethod) {
//            class_addMethod(cls, targetModel.aliasSelector, targetMethodIMP, typeEncoding);
//        }
//        class_replaceMethod(cls, roriginSelector, _objc_msgForward, typeEncoding);
//        [self.classHooked addObject:cls];
    }
    return YES;
}

static void dbx_track_forwardInvocation(id target, SEL selector, NSInvocation *invocation) {
    
}

+ (NSMutableSet<Class> *)classHooked {
    static dispatch_once_t once;
    static NSMutableSet *_classHooked = nil;
    dispatch_once(&once, ^{
        _classHooked = [NSMutableSet set];
    });
    return _classHooked;
}

@end
