//
//  DBXDebounce.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/22.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXDebounce.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "DBXDebounceDealloc.h"
#import <pthread.h>

static NSString *const DBXForwardInvocationSelectorName = @"__dbx_forwardInvocation:";
static NSString *const DBXSubclassPrefix = @"_DBXDebounce_";

@interface DBXDebounceRule ()
// 给规则加个私有的存放真实selector的属性
@property (nonatomic, assign) SEL aliasSelector;
@property(nonatomic, assign, readwrite, getter=isActive) BOOL active;
// 最后执行的时间
@property (nonatomic) NSTimeInterval lastTimeInvoke;
@property (nonatomic) NSInvocation *lastInvocation;


@end

@implementation DBXDebounceRule

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_get_main_queue();
    }
    return self;
}

- (DBXDebounceDealloc *)deallocObj {
    if (!self.target) {
        return nil;
    }
    DBXDebounceDealloc *dealloc = objc_getAssociatedObject(self.target, self.selector);
    if (!dealloc) {
        dealloc = [[DBXDebounceDealloc alloc] init];
        dealloc.rule = self;
        dealloc.cls = object_getClass(self.target);
        objc_setAssociatedObject(self.target, self.selector, dealloc, OBJC_ASSOCIATION_RETAIN);
    }
    return dealloc;
}

- (void)clearDeallocObj {
    objc_setAssociatedObject(self.target, self.selector, nil, OBJC_ASSOCIATION_RETAIN);
}

- (void)apply {
    [[DBXDebounce sharedInstance] applyRule:self];
}

- (SEL)aliasSelector {
    if (!_aliasSelector) {
        _aliasSelector = NSSelectorFromString([NSString stringWithFormat:@"__dbx_%@", NSStringFromSelector(self.selector)]);
    }
    return _aliasSelector;
}

- (void)invokingLastInvocation {
    DBXDebounceDealloc *dealloc = [self deallocObj];
    if (!dealloc) {
        return;
    }
    [self.lastInvocation invoke];
    self.lastInvocation = nil;
}

@end



@interface DBXDebounce ()
@property (nonatomic, assign) pthread_mutex_t lock;
@property (nonatomic) NSMapTable<id, NSMutableSet<NSString *> *> *targetSelectorsMap;
@property (nonatomic) NSMutableSet<Class> *classHooked;
@end

@implementation DBXDebounce

- (instancetype)init
{
    self = [super init];
    if (self) {
        _targetSelectorsMap = [NSMapTable weakToStrongObjectsMapTable];
        _classHooked = [NSMutableSet set];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXDebounce *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)addSelector:(SEL)selector toTarget:(id)target {
    if (!selector || !target) {
        return;
    }
    NSMutableSet *selectorsSet = [self.targetSelectorsMap objectForKey:target];
    if (!selectorsSet) {
        selectorsSet = [NSMutableSet set];
    }
    [selectorsSet addObject:NSStringFromSelector(selector)];
    [self.targetSelectorsMap setObject:selectorsSet forKey:target];
}

- (void)applyRule:(DBXDebounceRule *)rule {
    pthread_mutex_lock(&_lock);
    if (![DBXDebounce checkRuleValid:rule]) {
        return;
    }
    BOOL hadApply = objc_getAssociatedObject(rule.target, rule.selector);
    
    DBXDebounceDealloc *dealloc = rule.deallocObj;
    [dealloc lock];
    BOOL shouldApplly = YES;
    if ([DBXDebounce checkRuleValid:rule]) {
        /**
         检查规则的target的继承链里是否已经有添加规则了，
         同一个selector在一条继承链里只能有一个规则，否则无法区分是子类还是父类
         */
        NSArray *allTargets = [[self.targetSelectorsMap keyEnumerator] allObjects];
        for (id target in allTargets) {
            NSMutableSet *selectors = [self.targetSelectorsMap objectForKey:target];
            NSString *selectorName = NSStringFromSelector(rule.selector);
            // 找出要应用的selector
            if (![selectors containsObject:selectorName]) {
                continue;
            }
            // 已经应用的规则
            if (target == rule.target) {
                shouldApplly = NO;
                continue;;
            }
            // 继承链上的规则
            if (object_isClass(rule.target) && object_isClass(target)) {
                // 判定是都是一条继承链
                Class classRule = rule.target;
                Class classTarget = target;
                shouldApplly = ![classRule isSubclassOfClass:classTarget] && ![classTarget isSubclassOfClass:classRule];
                break;
            } else if (object_isClass(target) && target == object_getClass(rule.target)) {
                // 判定当前实例的类是否已经有规则应用了
                shouldApplly = NO;
                break;
            }
        }
        shouldApplly = shouldApplly && [self overrideMethod:rule];
        if (shouldApplly) {
            [self addSelector:rule.selector toTarget:rule.target];
            rule.active = YES;
        }
        
    } else {
        shouldApplly = NO;
    }
    if (!shouldApplly && !hadApply) {
        [rule clearDeallocObj];
    }
    [dealloc unlock];
    pthread_mutex_unlock(&_lock);
}

- (BOOL)overrideMethod:(DBXDebounceRule *)rule {
    Class isaClass = object_getClass(rule.target);
    Class ocClass = [rule.target class];
    NSString *isaClassName= NSStringFromClass(isaClass);
    Class cls;
    // 动态创建一个子类指向原本的cls，避免影响原cls
    if ([isaClassName containsString:DBXSubclassPrefix]) {
        cls = ocClass;
    } else if (object_isClass(rule.target)) {
        cls = rule.target;
    } else if (ocClass != isaClass) {
        cls = ocClass;
    } else {
        // 创建个动态类，并指向它
        const char *subClassName = [DBXSubclassPrefix stringByAppendingString:isaClassName].UTF8String;
        Class subClass = objc_getClass(subClassName);
        if (!subClass) {
            subClass = objc_allocateClassPair(ocClass, subClassName, 0);
            if (!subClass) {
                return NO;
            }
            [DBXDebounce hookClassFrom:subClass to:ocClass];
            [DBXDebounce hookClassFrom:object_getClass(subClass) to:ocClass];
            objc_registerClassPair(subClass);
        }
        object_setClass(rule.target, subClass);
        cls = subClass;
    }
    
    for (Class clsHooked in self.classHooked) {
        // 检查其子类是否被hook了
        if (clsHooked != cls && [clsHooked isSubclassOfClass:cls]) {
            return NO;
        }
    }
    
    [rule deallocObj].cls = cls;
    IMP targetOriginalForwardImp = class_getMethodImplementation(cls, @selector(forwardInvocation:));
    if (targetOriginalForwardImp != (IMP)dbx_forwardInvocation) {
        // 把cls的方法转发的方法转移到当前类里，即mt_forwardInvocation，然后重新加一个方法DBXForwardInvocationSelectorName保留原始的实现，因为cls里可能实现了forwardInvocation:
        IMP originalIMP = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)dbx_forwardInvocation, "v@:@");// 暂未找到C方法获取encoding的方式，先写死"v@:@"
        if (!originalIMP) {
            class_addMethod(cls, NSSelectorFromString(DBXForwardInvocationSelectorName), originalIMP, "v@:@");
        }
    }
    
    Method targetMethod = class_getInstanceMethod(cls, rule.selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    const char *typeEncoding = method_getTypeEncoding(targetMethod);
    if (targetMethodIMP != _objc_msgForward) {
        // 给cls添加一个新方法aliasSelector，实现为rule的selector
        class_addMethod(cls, rule.aliasSelector, targetMethodIMP, typeEncoding);
        class_replaceMethod(cls, rule.selector, _objc_msgForward, typeEncoding);
        [self.classHooked addObject:cls];
    }
    
    return YES;
}

+ (BOOL)checkRuleValid:(DBXDebounceRule *)rule {
    if (!rule.target || !rule.selector || rule.debounceInterval <= 0) {
        return NO;
    }
    if ([NSStringFromSelector(rule.selector) isEqualToString:@"forwardInvocation"]) {
        return NO;
    }
    NSString *className = NSStringFromClass([rule.target class]);
    if ([className isEqualToString:@"MTRule"] || [className isEqualToString:@"MTEngine"]) {
        return NO;
    }
    return YES;
}

+ (void)hookClassFrom:(Class)originalClass to:(Class)newClass {
    IMP newIMP = imp_implementationWithBlock(^(id self) {
        return newClass;
    });
    const char *methodType = method_getTypeEncoding(class_getInstanceMethod(originalClass, @selector(class)));
    class_replaceMethod(originalClass, @selector(class), newIMP, methodType);
}

static void dbx_forwardInvocation(id target, SEL selector, NSInvocation *invocation) {
    DBXDebounceDealloc *deallocObj = nil;
    if (object_isClass(target)) {
        deallocObj = objc_getAssociatedObject(object_getClass(invocation.target), invocation.selector);
    } else {
        deallocObj = objc_getAssociatedObject(invocation.target, invocation.selector);
    }
    BOOL aliasResponds = YES;
    Class cls = object_getClass(invocation.target);
    do {
        if (!deallocObj.rule) {
            deallocObj = objc_getAssociatedObject(cls, invocation.selector);
        }
        if ((aliasResponds = [cls instancesRespondToSelector:deallocObj.rule.aliasSelector])) {
            break;
        }
        deallocObj = nil;
    } while (!aliasResponds && (cls = class_getSuperclass(cls)));
    
    [deallocObj lock];
    if (aliasResponds) {
        dbx_handleInvocation(invocation, deallocObj.rule);
    }
    [deallocObj unlock];
}

static void dbx_handleInvocation(NSInvocation *invocation, DBXDebounceRule *rule) {
    if (!rule.isActive) {
        [invocation invoke];
        return;
    }
    if (rule.debounceInterval <= 0 ) {
        invocation.selector = rule.aliasSelector;
        [invocation invoke];
        return;
    }
    NSLog(@"%s", __func__);
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    switch (rule.model) {
        case DBXDebounceModelFirstOnly:
            {
                if (now - rule.lastTimeInvoke > rule.debounceInterval) {
                    invocation.selector = rule.aliasSelector;
                    [invocation invoke];
                    rule.lastTimeInvoke = now;
                    dispatch_async(rule.queue, ^{
                        rule.lastInvocation = nil;
                    });
                }
            }
            break;
        case DBXDebounceModelLastOnly:
            {
                invocation.selector = rule.aliasSelector;
                [invocation retainArguments];
                dispatch_async(rule.queue, ^{
                    rule.lastInvocation = invocation;
                    if (now - rule.lastTimeInvoke > rule.debounceInterval) {
                        rule.lastTimeInvoke = now;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(rule.debounceInterval * NSEC_PER_SEC)), rule.queue, ^{
                            [rule invokingLastInvocation];
                        });
                    }
                });
            }
            break;
        case DBXDebounceModelDebounce:
            {
                invocation.selector = rule.aliasSelector;
                [invocation retainArguments];
                dispatch_async(rule.queue, ^{
                    rule.lastInvocation = invocation;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(rule.debounceInterval * NSEC_PER_SEC)), rule.queue, ^{
                        if (rule.lastInvocation == invocation) {
                            [rule invokingLastInvocation];
                        }
                    });
                });
            }
            break;
        default:
            break;
    }
}

@end
