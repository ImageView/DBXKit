//
//  MnaDBHelper.m
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/11/14.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBHelper.h"
#import <objc/runtime.h>
// runtime辅助工具
@implementation MnaDBHelper

+ (UIImage *)imageWithName:(NSString *)name {
    static NSBundle *resourceBundle = nil;
    if (!resourceBundle) {
        NSBundle *mainBundle = [NSBundle bundleForClass:self];
        NSString *resourcePath = [mainBundle pathForResource:@"MnaDebuggingOnLine" ofType:@"bundle"];
        resourceBundle = [NSBundle bundleWithPath:resourcePath] ?: mainBundle;
    }
    UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
    return image;
}

// name##pptClass
+ (NSArray *)getIvarList:(Class)cls {
    unsigned int count = 0;
    Ivar *ivars = nil;
    ivars = class_copyIvarList(cls, &count);
    NSMutableArray *varsAry = [NSMutableArray array];
    for (unsigned int i = 0; i < count; i ++) {
        Ivar ivar = nil;
        ivar = ivars[i];
        const char *cName = ivar_getName(ivar);
        const char *cType = ivar_getTypeEncoding(ivar);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        NSString *type = [[[NSString stringWithCString:cType encoding:NSUTF8StringEncoding]
                           stringByReplacingOccurrencesOfString:@"@"
                           withString:@""]
                          stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [varsAry addObject:[NSString stringWithFormat:@"%@##%@", name, type]];
    }
    free(ivars);
    return varsAry;
}

// name
+ (NSArray *)getProperties:(Class)cls {
    unsigned int count = 0;
    objc_property_t *properties = nil;
    properties = class_copyPropertyList(cls, &count);
    NSMutableArray *pptArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        objc_property_t property = nil;
        property = properties[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [pptArray addObject:name];
    }
    free(properties);
    return pptArray;
}

+ (NSString *)getPropertyClass:(NSString *)property inClass:(Class)class {
    objc_property_t p = class_getProperty(class, property.UTF8String);
    const char *cName = property_getAttributes(p);
    NSString *attrs = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
    NSInteger dotLoc = [attrs rangeOfString:@","].location;
    NSString *code = nil;
    NSInteger loc = 3;
    if (dotLoc == NSNotFound && attrs.length > 3) {
        code = [attrs substringFromIndex:loc];
    } else if (dotLoc != NSNotFound && dotLoc - loc - 1 > 0) {
        code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc - 1)];
    }
    return code;
}

+ (void)showShareActivityWithItems:(NSArray *)items {
    if (!items.count) return;
    
    UIWindow *window = nil;
    if ([UIApplication sharedApplication].keyWindow.rootViewController) {
        window = [UIApplication sharedApplication].keyWindow;
    } else {
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    UIViewController *presentingVC = [[UIViewController alloc] init];
    presentingVC.view.bounds = window.bounds;
    [window addSubview:presentingVC.view];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType,
                                              BOOL completed,
                                              NSArray * _Nullable returnedItems,
                                              NSError * _Nullable activityError) {
        [presentingVC.view removeFromSuperview];
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [presentingVC presentViewController:activityVC animated:YES completion:nil];
    } else {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popoverController presentPopoverFromRect:CGRectMake(presentingVC.view.frame.size.width/2,
                                                             presentingVC.view.frame.size.height/5, 0, 0)
                                           inView:presentingVC.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
}

+ (void)showMessage:(NSString *)message inVC:(UIViewController *)vc {
    UIAlertController *tempAlert = [UIAlertController alertControllerWithTitle:message
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [tempAlert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:tempAlert animated:YES completion:nil];
}

//+ (UIViewController *)getViewController:(UIView *)view {
//    UIResponder *responder = view;
//    while ((responder = responder.nextResponder)) {
//        if ([responder isKindOfClass:[UIViewController class]]) {
//            return (UIViewController *)responder;
//        }
//    }
//    return nil;
//}

@end
