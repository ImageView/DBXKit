//
//  DBXARUtils.m
//  DBXKit
//
//  Created by asherluo on 2022/7/16.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXARUtils.h"
#import "UIView+DBXAR.h"
#import "DBXViewUtils.h"
#import "UIView+DBXCore.h"
#import <objc/runtime.h>

@implementation DBXARUtils

+ (NSString *)dbx_reportIDOfView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        return [self dbx_targetActionOfView:view];
    }
    return [self dbx_indexPathInCurrViewControllerOfView:view];
}

+ (NSInteger)dbx_itemIndexForResponder:(UIResponder *)responder {
    NSString *classString = NSStringFromClass(responder.class);

    NSInteger index = -1;
    NSArray<UIResponder *> *brothersResponder = [self brothersElementForResponder:responder];

    for (UIResponder *res in brothersResponder) {
        if ([classString isEqualToString:NSStringFromClass(res.class)]) {
            index ++;
        }
        if (res == responder) {
            break;
        }
    }

    /* 序号说明
     -1：nextResponder 不是父视图或同类元素，比如 controller.view，涉及路径不带序号
     >=0：元素序号
     */
    return index;
}

// view在在父视图的节点
+ (NSString *)dbx_nodeOfView:(UIView *)view {
    NSString *className = NSStringFromClass(view.class);
    NSInteger index = [self dbx_itemIndexForResponder:view];
    if (index < 0) {
        return className;
    }
    return [NSString stringWithFormat:@"%@[%ld]", className, (long)index];
}

+ (NSString *)dbx_indexPathInCurrViewControllerOfView:(UIView *)view {
    NSMutableArray *pathList = [NSMutableArray array];
    UIViewController *vc = [DBXViewUtils dbx_getViewController:view];
    
    while ([view isKindOfClass:[UIView class]]) {
        [pathList addObject:[self dbx_nodeOfView:view]];
        view = (UIView *)view.nextResponder;
    }
    [pathList addObject:NSStringFromClass(vc.class)];
    
    NSString *pathStr = [[[pathList reverseObjectEnumerator] allObjects] componentsJoinedByString:@"/"];
    return pathStr;
}

/// 寻找所有兄弟元素
+ (NSArray <UIResponder *> *)brothersElementForResponder:(UIResponder *)responder {
    if ([responder isKindOfClass:UIView.class]) {
        UIResponder *next = [responder nextResponder];
        if ([next isKindOfClass:UIView.class]) {
            NSArray<UIView *> *subViews = [(UIView *)next subviews];
            if ([next isKindOfClass:UISegmentedControl.class]) {
                // UISegmentedControl subviews顺序会变化，需要用坐标排序固定顺序
                NSArray<UIView *> *brothers = [subViews sortedArrayUsingComparator:^NSComparisonResult (UIView *obj1, UIView *obj2) {
                    if (obj1.frame.origin.x > obj2.frame.origin.x) {
                        return NSOrderedDescending;
                    } else {
                        return NSOrderedAscending;
                    }
                }];
                return brothers;
            }
            return subViews;
        }
    } else if ([responder isKindOfClass:UIViewController.class]) {
        return [(UIViewController *)responder parentViewController].childViewControllers;
    }
    return nil;
}

+ (NSString *)dbx_targetActionOfView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        UIControl *control = (UIControl *)view;
        
        if (!control.allTargets.count) {
            return nil;
        }
        // 优先找当前VC，没找到则任选一个
        id findTarget = nil;
        for (id target in control.allTargets) {
            if (target == control.dbx_vc) {
                findTarget = target;
                break;
            }
        }
        if (!findTarget) {
            findTarget = control.allTargets.anyObject;
        }
        NSArray *actions = [control actionsForTarget:findTarget forControlEvent:UIControlEventTouchUpInside];
        
        NSString *findAction = nil;
        for (NSString *action in actions) {
            if ([findTarget respondsToSelector:NSSelectorFromString(action)]) {
                findAction = action;
                break;
            }
        }
        return [self reportIDByTarget:findTarget actionString:findAction];
    }
    return nil;
}

+ (NSString *)reportIDByTarget:(id)target actionString:(NSString *)action {
    NSString *targetClassName = NSStringFromClass([target class]);
    
    NSLog(@"targetClassName:%@ action:%@",targetClassName,action);
    return [NSString stringWithFormat:@"%@_%@", targetClassName, action];
}

//#pragma mark - Private

@end
