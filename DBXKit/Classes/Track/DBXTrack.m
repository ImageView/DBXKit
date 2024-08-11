//
//  DBXTrack.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/8.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXTrack.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "DBXCore.h"
#import <pthread.h>

static NSString *const DBXTrackForwardInvocationSelectorName = @"__dbx_track_forwardInvocation:";
static NSString *const DBXTrackSubclassPrefix = @"_DBXTrack_";

@interface DBXTrack ()
// 记录被修改了impl的类
@property (class, readonly, nonatomic) NSMutableSet<Class> *classHooked;
@property (class, readonly, nonatomic, assign) pthread_mutex_t mutexLock;

@end

@implementation DBXTrack


+ (BOOL)dbx_trackTarget:(id)target
                 condition:(ConditionBlock)conditionBlock
                    before:(BeforeInvocateBlock)beforeBlock
                     after:(AfterInvocateBlock)afterBlock {
    if ([DBXCenter sharedConfig].closeUnsafeFeatures) {
        return NO;
    }
    if (!target) {
        return NO;
    }
    DBXTrackTarget *targetModel = [[DBXTrackTarget alloc] init];
    targetModel.target = target;
    targetModel.conditionBlock = conditionBlock;
    targetModel.beforeBlock = beforeBlock;
    targetModel.afterBlock = afterBlock;
    // 创建关联对象，以便在forwardInvocation:里获取到DBXTrackTarget对象
    [targetModel createAccociateObject];
    
    return [self dbx_trackTarget:targetModel];
}

// return 是否正在追踪
+ (BOOL)dbx_trackTarget:(DBXTrackTarget *)targetModel {
    BOOL succ = NO;
    pthread_mutex_t lock = self.mutexLock;
    pthread_mutex_lock(&lock);
    [targetModel.accociatedObj lock];
    
    succ = [self overrideMethod:targetModel];
    
    [targetModel.accociatedObj unlock];
    pthread_mutex_unlock(&lock);
    return succ;
}

+ (BOOL)overrideMethod:(DBXTrackTarget *)targetModel {
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
            [DBXRuntimeUtils hookClassFrom:subClass to:ocClass];
            [DBXRuntimeUtils hookClassFrom:object_getClass(subClass) to:ocClass];
            objc_registerClassPair(subClass);
        }
        object_setClass(targetModel.target, subClass);
        cls = subClass;
    }
    
    for (Class clsHooked in self.classHooked) {
        // 检查其子类是否被hook了
        if (clsHooked != cls && [clsHooked isSubclassOfClass:cls]) {
            return YES;
        }
    }
    dbx_trackClass(cls, targetModel.conditionBlock);
    dbx_trackClass(object_getClass(cls), targetModel.conditionBlock);
    return YES;
}

void dbx_trackClass(Class cls, ConditionBlock block) {
    IMP targetOriginalForwardImp = class_getMethodImplementation(cls, @selector(forwardInvocation:));
    if (targetOriginalForwardImp != (IMP)dbx_track_forwardInvocation) {
        IMP originalIMP = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)dbx_track_forwardInvocation, "v@:@");
        if (originalIMP) {
            class_addMethod(cls, NSSelectorFromString(DBXTrackForwardInvocationSelectorName), originalIMP, "v@:@");
        }
        [DBXTrack.classHooked addObject:cls];
    }
    
    Class listCls;
    if ([NSStringFromClass(cls) containsString:DBXTrackSubclassPrefix]) {
        listCls = class_getSuperclass(cls);
    }
    unsigned int outCount;
    Method *methods = class_copyMethodList(listCls, &outCount);
    
    for (int i = 0; i < outCount; i ++) {
        Method tempMethod = *(methods + i);
        SEL selector = method_getName(tempMethod);
        NSString *selectorName = NSStringFromSelector(selector);
        if (dbx_isInBlackList(selectorName)) {
            continue;
        }
        if ([selectorName rangeOfString:@"dbx_"].location != NSNotFound) {
            continue;
        }
        if (block && !block(selector)) {
            continue;;
        }
        char *returnType = method_copyReturnType(tempMethod);
        
        dbx_track_replaceMethod(cls, selector, returnType);
        free(returnType);
    }
}

BOOL dbx_track_replaceMethod(Class cls, SEL originSelector, char *returnType) {
    Method targetMethod = class_getInstanceMethod(cls, originSelector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (targetMethodIMP != _objc_msgForward) {
        const char *typeEncoding = method_getTypeEncoding(targetMethod);

        SEL aliasSelector = [DBXTrackTarget aliasSelector:originSelector];
        // 给cls添加一个新方法aliasSelector，实现为rule的selector
        Method aliMethod = class_getInstanceMethod(cls, aliasSelector);
        Method superAliMethod = class_getInstanceMethod(class_getSuperclass(cls), aliasSelector);
        if (![cls instanceMethodForSelector:aliasSelector] || aliMethod == superAliMethod) {
            class_addMethod(cls, aliasSelector, targetMethodIMP, typeEncoding);
        }
        class_replaceMethod(cls, originSelector, _objc_msgForward, typeEncoding);
//        [self.classHooked addObject:cls];
    }
    return YES;
}

//是否在默认的黑名单中
BOOL dbx_isInBlackList(NSString *methodName) {
    static NSArray *defaultBlackList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBlackList = @[/*UIViewController的:*/@".cxx_destruct", @"dealloc", @"_isDeallocating", @"release", @"autorelease", @"retain", @"Retain", @"_tryRetain", @"copy", /*UIView的:*/ @"nsis_descriptionOfVariable:", /*NSObject的:*/@"respondsToSelector:", @"class", @"methodSignatureForSelector:", @"allowsWeakReference", @"retainWeakReference", @"init", @"forwardInvocation:"];
    });
    return ([defaultBlackList containsObject:methodName]);
}

static void dbx_track_forwardInvocation(id target, SEL selector, NSInvocation *invocation) {
    SEL originInvacationSelector = invocation.selector;
    NSArray *argumes = [invocation dbx_getArgumes];

    DBXTrackAssociatedObj *accObj = objc_getAssociatedObject(target, &kDBXTrackAccociatedObjKey);
    if (!accObj) {
        // 如果没有实例对象的关联对象，尝试找其class的关联对象
        accObj = objc_getAssociatedObject(object_getClass(target), &kDBXTrackAccociatedObjKey);
    }
    [accObj lock];
    DBXTrackTarget *targetModel = accObj.targetModel;
    if (targetModel && targetModel.beforeBlock) {
        targetModel.beforeBlock(target, originInvacationSelector, argumes);
    }
    
    [invocation setSelector:[DBXTrackTarget aliasSelector:originInvacationSelector]];
    [invocation invoke];
    
    DBXLog(@"追踪函数：%@", NSStringFromSelector(originInvacationSelector));
    
    if (targetModel && targetModel.afterBlock) {
        id result = [invocation dbx_getReturnValue];
        targetModel.afterBlock(target, originInvacationSelector, argumes, result);
    }
    [accObj unlock];
}

+ (NSMutableSet<Class> *)classHooked {
    static dispatch_once_t once;
    static NSMutableSet *_classHooked = nil;
    dispatch_once(&once, ^{
        _classHooked = [NSMutableSet set];
    });
    return _classHooked;
}

+ (pthread_mutex_t)mutexLock {
    static dispatch_once_t once;
    static pthread_mutex_t _lock;
    dispatch_once(&once, ^{
        pthread_mutex_init(&_lock, NULL);
    });
    return _lock;
}

@end
