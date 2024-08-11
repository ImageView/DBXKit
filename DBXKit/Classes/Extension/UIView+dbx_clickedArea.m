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
static const NSString *KEY_CLICKED_AREA_EDGE_INSETS = @"kDBXClickedAreaEdgeInsets";
static const NSString *KEY_CLICKED_AUTO_FIX_SIZE = @"kDBXClickedAutoFixMinSize";
static const NSLock *createClassLock = nil;

@interface UIView ()


@end

@implementation UIView (ClickedArea)


- (UIEdgeInsets)dbx_clickedAreaEdgeInsets {
    NSValue *value = objc_getAssociatedObject(self, &KEY_CLICKED_AREA_EDGE_INSETS);
    return value ? [value UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setDbx_clickedAreaEdgeInsets:(UIEdgeInsets)dbx_clickedAreaEdgeInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:dbx_clickedAreaEdgeInsets];
    objc_setAssociatedObject(self, &KEY_CLICKED_AREA_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)dbx_autoFixMinSize {
    NSValue *value = objc_getAssociatedObject(self, &KEY_CLICKED_AUTO_FIX_SIZE);
    return value ? [value CGSizeValue] : CGSizeZero;
}

- (void)setDbx_autoFixMinSize:(CGSize)dbx_autoFixMinSize {
    NSValue *value = [NSValue valueWithCGSize:dbx_autoFixMinSize];
    objc_setAssociatedObject(self, &KEY_CLICKED_AUTO_FIX_SIZE, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dbx_enableExtendedClickedAreaEdgeInsets:(UIEdgeInsets)clickedAreaEdgeInsets {
    self.dbx_clickedAreaEdgeInsets = clickedAreaEdgeInsets;
    [self dbx_enableExtendedClickedArea];
}

- (void)dbx_enableExtendedClickedAreaFixMinSize:(CGSize)minSize {
    self.dbx_autoFixMinSize = minSize;
    [self dbx_enableExtendedClickedArea];
}

- (void)dbx_enableExtendedClickedAreaFix44x44 {
    [self dbx_enableExtendedClickedAreaFixMinSize:CGSizeMake(44, 44)];
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
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        createClassLock = [[NSLock alloc] init];
    });
    [createClassLock lock];
    Class subClass = objc_getClass(subClassName);
    if (!subClass) {
        subClass = objc_allocateClassPair(ocClass, subClassName, 0);
        if (subClass) {
            [DBXRuntimeUtils hookClassFrom:subClass to:ocClass];
            [DBXRuntimeUtils hookClassFrom:object_getClass(subClass) to:ocClass];
            objc_registerClassPair(subClass);

            Method originalMethod = class_getInstanceMethod(subClass, @selector(pointInside:withEvent:));
            IMP orignalIMP = method_getImplementation(originalMethod);
            if (orignalIMP != (IMP)dbx_extenedPointHittest) {
                class_replaceMethod(subClass, @selector(pointInside:withEvent:), (IMP)dbx_extenedPointHittest, "B@:@{CGPoint=dd}@");
            }
        }
    }
    [createClassLock unlock];
    if (subClass) {
        object_setClass(self, subClass);
    }
}

- (CGRect)dbx_extendedClikedArea {
    CGRect expandedRect;
    UIEdgeInsets insets = self.dbx_clickedAreaEdgeInsets;
    if (!UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero)) {
        expandedRect = UIEdgeInsetsInsetRect(self.bounds, insets);
    } else if (!CGSizeEqualToSize(self.dbx_autoFixMinSize, CGSizeZero)) {
        CGSize size = self.dbx_autoFixMinSize;
        CGFloat newWidth = MAX(self.frame.size.width, size.width);
        CGFloat newHeight = MAX(self.frame.size.height, size.height);
        expandedRect = CGRectMake((self.frame.size.width - newWidth) / 2.0,
                                  (self.frame.size.height - newHeight) / 2.0,
                                  newWidth,
                                  newHeight);
    } else {
        expandedRect = self.bounds;
    }
    return expandedRect;
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
}

static BOOL dbx_extenedPointHittest(id target, SEL selector, CGPoint point, UIEvent *event) {
    UIView *view = target;
    return CGRectContainsPoint([view dbx_extendedClikedArea], point);
}

@end
