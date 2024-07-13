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
#import "DBXLog.h"

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

- (instancetype)initWithTarget:(id)target selector:(SEL)selector debounceInterval:(NSTimeInterval)debounceInterval {
    self = [super init];
    if (self) {
        _target = target;
        _selector = selector;
        _debounceInterval = debounceInterval;
        _model = DBXDebounceModeDebounce;
        _queue = dispatch_get_main_queue();
        _lastTimeInvoke = 0;
    }
    return self;
}

- (void)setActive:(BOOL)active {
    _active = active;
    /**
     deallocObj跟target和select绑定
     如果这target和select，deallocObj就唯一，deallocObj里的rule就唯一
     此时用deallocObj跟target生成一个新的的rule1，就会出现rule != deallocObj.rule的情况（主要是active值）
     不考虑其他属性的情况下，保持两边的active同步，其他参数一遍也不会变
     */
    if (self.deallocObj.rule != self && self.deallocObj.rule.active != active) {
        self.deallocObj.rule.active = active;
    }
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

- (BOOL)apply {
    return [[DBXDebounce sharedInstance] applyRule:self];
}

- (BOOL)discard {
    return [[DBXDebounce sharedInstance] discardRule:self];
}

- (SEL)aliasSelector {
    if (!_aliasSelector) {
        _aliasSelector = NSSelectorFromString([NSString stringWithFormat:@"__dbx_%@", NSStringFromSelector(self.selector)]);
    }
    return _aliasSelector;
}

- (void)invokingLastInvocation {
    DBXDebounceDealloc *dealloc = [self deallocObj];
    if (!dealloc || !dealloc.rule.isActive) {
        return;
    }
    [self.lastInvocation invoke];
    self.lastInvocation = nil;
}

@end



@interface DBXDebounce ()
@property (nonatomic, assign) pthread_mutex_t lock;
// 记录target中添加了规则的select
@property (nonatomic) NSMapTable<id, NSMutableSet<NSString *> *> *targetSelectorsMap;
// 记录被修改了impl的类
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

- (BOOL)containsSelector:(SEL)selector onTarget:(id)target {
    return [[self.targetSelectorsMap objectForKey:target] containsObject:NSStringFromSelector(selector)];
}

- (BOOL)containsSelector:(SEL)selector onTargetClass:(Class)cls {
    for (id target in [self.targetSelectorsMap.keyEnumerator allObjects]) {
        if (object_getClass(target) == cls &&
            [[self.targetSelectorsMap objectForKey:target] containsObject:NSStringFromSelector(selector)]) {
            return YES;
        }
    }
    return NO;
}
/**
 记录注册了规则的 target-selector

 @param selector 方法名
 @param target 对象，类，元类
 */
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

/**
 移除规则 target-selector

 @param selector 方法名
 @param target 对象，类，元类
 */
- (void)removeSelector:(SEL)selector ofTarget:(id)target {
    if (!selector || !target) {
        return;
    }
    NSMutableSet *selectorsSet = [self.targetSelectorsMap objectForKey:target];
    if (!selectorsSet) {
        selectorsSet = [NSMutableSet set];
    }
    [selectorsSet removeObject:NSStringFromSelector(selector)];
    [self.targetSelectorsMap setObject:selectorsSet forKey:target];
}

- (BOOL)applyRule:(DBXDebounceRule *)rule {
    pthread_mutex_lock(&_lock);
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
                continue;
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
    return shouldApplly;
}

- (BOOL)discardRule:(DBXDebounceRule *)rule {
    pthread_mutex_lock(&_lock);
    DBXDebounceDealloc *dealloc = rule.deallocObj;
    [dealloc lock];
    BOOL shouldDiscard = NO;
    if ([DBXDebounce checkRuleValid:rule]) {
        [self removeSelector:rule.selector ofTarget:rule.target];
        shouldDiscard = [self reoverMethod:rule];
        rule.active = NO;
    }
    
    [dealloc unlock];
    pthread_mutex_unlock(&_lock);
    return shouldDiscard;
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
        // 把cls的方法转发的方法转移到当前类里，即dbx_forwardInvocation，然后重新加一个方法DBXForwardInvocationSelectorName保留原始的实现，因为cls里可能实现了forwardInvocation:
        IMP originalIMP = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)dbx_forwardInvocation, "v@:@");// 暂未找到C方法获取encoding的方式，先写死"v@:@"
        if (originalIMP) {
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

// 恢复之前修改的impl
- (BOOL)reoverMethod:(DBXDebounceRule *)rule {
    Class cls;
    if (object_isClass(rule.target)) {
        cls = rule.target;
        if ([self containsSelector:rule.selector onTargetClass:rule.target]) {
            return NO;
        }
    } else {
        // 把target指回原class
        DBXDebounceDealloc *allocObj = rule.deallocObj;
        cls = allocObj.cls;
        NSString *subClass = NSStringFromClass(cls);
        if ([subClass hasPrefix:DBXSubclassPrefix]) {
            Class originalClass = NSClassFromString([subClass stringByReplacingOccurrencesOfString:DBXSubclassPrefix withString:@""]);
            if (originalClass) {
                object_setClass(rule.target, originalClass);
            }
        }
        // 去除记录
        if ([self containsSelector:rule.selector onTarget:rule.target] || [self containsSelector:rule.selector onTargetClass:rule.class]) {
            return NO;
        }
    }
    // 把selector恢复到原本的实现
    Method targetMethod = class_getInstanceMethod(cls, rule.selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (targetMethodIMP == _objc_msgForward) {
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        Method originalMethod = class_getInstanceMethod(cls, rule.aliasSelector);
        IMP originalIMP = method_getImplementation(originalMethod);
        class_replaceMethod(cls, rule.selector, originalIMP, typeEncoding);
    }
    
    // 把forward转回去
    if (class_getMethodImplementation(cls, @selector(forwardInvocation:)) == (IMP)dbx_forwardInvocation) {
        Method originalForwardMethod = class_getInstanceMethod(cls, NSSelectorFromString(DBXForwardInvocationSelectorName));
        Method objectMethod = class_getInstanceMethod(NSObject.class, @selector(forwardInvocation:));
        class_replaceMethod(cls, @selector(forwardInvocation:), method_getImplementation(originalForwardMethod?:objectMethod), "v@:@");// 暂未找到C方法获取encoding的方式，先写死"v@:@"

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
    if ([className isEqualToString:@"DBXDebounceRule"] || [className isEqualToString:@"DBXDebounce"]) {
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
            // 实例中没有关联对象则尝试从类的关联中获取，因为rule可能绑定到类上了
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
    DBXDebounceShouldInvote shouldInvote = dbx_invokeFilterBlock(rule, invocation);
    if (shouldInvote == DBXDebounceShouldNotInvote) {
        DBXLog(@"不执行 target:%@, select:%s", invocation.target, invocation.selector);
        return;
    }
    if (rule.debounceInterval <= 0 || shouldInvote == DBXDebounceShouldInvoteIgnoreRule) {
        DBXLog(@"忽略规则，立即执行 target:%@, select:%s", invocation.target, invocation.selector);
        invocation.selector = rule.aliasSelector;
        [invocation invoke];
        return;
    }
//    DBXLog(@"按规则执行 target:%@, select:%s", invocation.target, invocation.selector);
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    switch (rule.model) {
        case DBXDebounceModeFirstOnly:
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
        case DBXDebounceModeLastOnly:
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
        default:
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
    }
}

static DBXDebounceShouldInvote dbx_invokeFilterBlock(DBXDebounceRule *rule, NSInvocation *originalInvocation) {
    if (!rule.shouldInvokeImmediatelyBlock || ![rule.shouldInvokeImmediatelyBlock isKindOfClass:NSClassFromString(@"NSBlock")]) {
        return DBXDebounceShouldInvoteInRule;
    }
    NSMethodSignature *filterBlockSignature = [NSMethodSignature signatureWithObjCTypes:dbx_blockMethodSignature(rule.shouldInvokeImmediatelyBlock)];
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:filterBlockSignature];
    NSUInteger numberOfArguments = filterBlockSignature.numberOfArguments;
    if (numberOfArguments > originalInvocation.methodSignature.numberOfArguments) {
        NSLog(@"shouldInvokeImmediatelyBlock block 参数过多");
        return DBXDebounceShouldInvoteInRule;
    }
    
    if (numberOfArguments > 1) {
        [blockInvocation setArgument:&rule atIndex:1];
    }
    void *argBuf = NULL;
    for (NSUInteger idx = 2; idx < numberOfArguments; idx++) {
        const char *type = [originalInvocation.methodSignature getArgumentTypeAtIndex:idx];
        NSUInteger argSize;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        argBuf = realloc(argBuf, argSize);
        if (!argBuf) {
            DBXLog(@"Block参数初始化失败");
            return DBXDebounceShouldInvoteInRule;
        }
        [originalInvocation getArgument:argBuf atIndex:idx];
        [blockInvocation setArgument:argBuf atIndex:idx];
    }
    
    [blockInvocation invokeWithTarget:rule.shouldInvokeImmediatelyBlock];
//    [blockInvocation invoke];
    DBXDebounceShouldInvote returnValue = DBXDebounceShouldInvoteInRule;
    [blockInvocation getReturnValue:&returnValue];
    if (argBuf != NULL) {
        free(argBuf);
    }
    return returnValue;
}

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

struct _DBXBlockDescriptor {
    unsigned long reserved;
    unsigned long size;
    void *rest[1];
};

struct _DBXBlock {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct _DBXBlockDescriptor *descriptor;
};

static const char * dbx_blockMethodSignature(id blockObj) {
    struct _DBXBlock *block = (__bridge void *)blockObj;
    struct _DBXBlockDescriptor *descriptor = block->descriptor;
    
    assert(block->flags & BLOCK_HAS_SIGNATURE);
    
    int index = 0;
    if(block->flags & BLOCK_HAS_COPY_DISPOSE)
        index += 2;
    
    return descriptor->rest[index];
}

@end

@implementation NSObject (DBXDebounce)

- (DBXDebounceRule *)dbx_performSelectorDebounce:(SEL)selector debounceInterval:(NSTimeInterval)debounceInterval mode:(DBXDebounceMode)debounceMode {
    return [self dbx_performSelectorDebounce:selector debounceInterval:debounceInterval mode:DBXDebounceModeDebounce queue:dispatch_get_main_queue() shouldInvokeImmediatelyBlock:nil];
}

- (DBXDebounceRule *)dbx_performSelectorDebounce:(SEL)selector debounceInterval:(NSTimeInterval)debounceInterval mode:(DBXDebounceMode)debounceMode queue:(dispatch_queue_t)queue shouldInvokeImmediatelyBlock:(id)block {
    DBXDebounceDealloc *dealloc = objc_getAssociatedObject(self, selector);
    BOOL isNewRule = NO;
    DBXDebounceRule *rule = dealloc.rule;
    if (!rule) {
        rule = [[DBXDebounceRule alloc] initWithTarget:self selector:selector debounceInterval:debounceInterval];
        isNewRule = YES;
    }
    rule.model = debounceMode;
    rule.shouldInvokeImmediatelyBlock = block;
    rule.queue = queue ?: dispatch_get_main_queue();
    
    if (isNewRule) {
        return [rule apply] ? rule : nil;
    }
    return rule;
}

@end
