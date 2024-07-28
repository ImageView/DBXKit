//
//  UIView+dbx_clickedArea.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/07/27.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "UIView+dbx_clickedArea.h"
#import <objc/runtime.h>
#import "DBXCore.h"

static NSString *const DBXButtonSubclassPrefix = @"_DBXClickedButton_";

@interface UIView ()
// 存储原始IMP
//@property (nonatomic, strong) NSValue *orignalIMPStorage;
@end

@implementation UIView (ClickedArea)

static const NSString *KEY_CLICKED_AREA_EDGE_INSETS = @"kDBXClickedAreaEdgeInsets";

- (UIEdgeInsets)dbx_clickedAreaEdgeInsets {
    NSValue *value = objc_getAssociatedObject(self, &KEY_CLICKED_AREA_EDGE_INSETS);
    return value ? [value UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setDbx_clickedAreaEdgeInsets:(UIEdgeInsets)dbx_clickedAreaEdgeInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:dbx_clickedAreaEdgeInsets];
    objc_setAssociatedObject(self, &KEY_CLICKED_AREA_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (void)setOrignalIMPStorage:(NSValue *)orignalIMPStorage {
//    objc_setAssociatedObject(self, @selector(orignalIMPStorage), orignalIMPStorage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (NSValue *)orignalIMPStorage {
//    return objc_getAssociatedObject(self, @selector(orignalIMPStorage));
//}

- (void)dbx_enableExtendedClickedAreaEdgeInsets:(UIEdgeInsets)clickedAreaEdgeInsets {
    self.dbx_clickedAreaEdgeInsets = clickedAreaEdgeInsets;
    [self dbx_enableExtendedClickedArea];
}

- (void)dbx_enableExtendedClickedArea {
    if ([DBXCenter sharedConfig].closeUnsafeFeatures) {
        return;
    }
    Class isaClass = object_getClass(self);
    NSString *isaClassName = NSStringFromClass(isaClass);
    if ([isaClassName hasPrefix:DBXButtonSubclassPrefix]) {
        return;
    }
    // 创建个动态类，并指向它
    Class ocClass = [self class];
    const char *subClassName = [DBXButtonSubclassPrefix stringByAppendingString:isaClassName].UTF8String;
    Class subClass = objc_getClass(subClassName);
    if (!subClass) {
        subClass = objc_allocateClassPair(ocClass, subClassName, 0);
        if (subClass) {
            hookClassFrom(subClass, ocClass);
            hookClassFrom(object_getClass(subClass), ocClass);
            objc_registerClassPair(subClass);
            
            Method originalMethod = class_getInstanceMethod(subClass, @selector(pointInside:withEvent:));
            IMP orignalIMP = method_getImplementation(originalMethod);
            if (orignalIMP != (IMP)dbx_extenedPointHittest) {
                class_replaceMethod(subClass, @selector(pointInside:withEvent:), (IMP)dbx_extenedPointHittest, "B@:@{CGPoint=dd}@");
            }
        }
    }
    
//    self.orignalIMPStorage = [NSValue valueWithPointer:orignalIMP];
    object_setClass(self, subClass);
}

- (void)dbx_disableExtendedClickedArea {
    if ([DBXCenter sharedConfig].closeUnsafeFeatures) {
        return;
    }
    Class isaClass = object_getClass(self);
    NSString *isaClassName = NSStringFromClass(isaClass);
    if (![isaClassName hasPrefix:DBXButtonSubclassPrefix]) {
        return;
    }
    Class originalClass = NSClassFromString([isaClassName stringByReplacingOccurrencesOfString:DBXButtonSubclassPrefix withString:@""]);
    if (originalClass) {
        object_setClass(self, originalClass);
    }
//    Method method = class_getInstanceMethod(isaClass, @selector(pointInside:withEvent:));
//    IMP methodIMP = method_getImplementation(method);
//    if (methodIMP != (IMP)dbx_extenedPointHittest) {
//        return;
//    }
//    IMP origmalIMP = (IMP)[self.orignalIMPStorage pointerValue];
//    class_replaceMethod(isaClass, @selector(pointInside:withEvent:), origmalIMP, "B@:@{CGPoint=dd}@");
//    self.orignalIMPStorage = nil;
}

static BOOL dbx_extenedPointHittest(id target, SEL selector, CGPoint point, UIEvent *event) {
    UIView *view = target;
    UIEdgeInsets insets = view.dbx_clickedAreaEdgeInsets;
    CGRect expandedRect = UIEdgeInsetsInsetRect(view.bounds, insets);
    return CGRectContainsPoint(expandedRect, point);
}

static void hookClassFrom(Class originalClass, Class newClass) {
    IMP newIMP = imp_implementationWithBlock(^(id self) {
        return newClass;
    });
    const char *methodType = method_getTypeEncoding(class_getInstanceMethod(originalClass, @selector(class)));
    class_replaceMethod(originalClass, @selector(class), newIMP, methodType);
}



@end
