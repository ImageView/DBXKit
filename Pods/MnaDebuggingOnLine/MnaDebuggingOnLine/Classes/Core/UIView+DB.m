//
//  UIView+DB.m
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/11/7.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "UIView+DB.h"
#import "MnaRuntime.h"
// UIView支持拖拽
@implementation UIView (DB)

static char kAssociatedObjectKey_db_hitTestBlock;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        DBXExtendImplementationOfNonVoidMethodWithTwoArguments([UIView class], @selector(hitTest:withEvent:), CGPoint, UIEvent *, UIView *, ^UIView *(UIView *selfObject, CGPoint point, UIEvent *event, UIView *originReturnValue) {
            if (selfObject.db_hitTestBlock) {
                UIView *view = selfObject.db_hitTestBlock(point, event, originReturnValue);
                return view;
            }
            return originReturnValue;
        });
    });
}

- (void)setDb_hitTestBlock:(__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))db_hitTestBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_db_hitTestBlock, db_hitTestBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))db_hitTestBlock {
    return (__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_db_hitTestBlock);
}

- (void)allowFollow {
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesView:)];
    [self addGestureRecognizer:panGes];
}

- (void)panGesView:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;

    CGPoint translation = [gesture translationInView:view.superview];
    [gesture setTranslation:CGPointZero inView:gesture.view];
    view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
}

- (UIViewController *)dbx_viewController {
    UIResponder *responder = self;
    while ((responder = responder.nextResponder)) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

@end
