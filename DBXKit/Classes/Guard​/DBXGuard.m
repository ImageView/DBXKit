//
//  DBXGuard.m
//  DBXKit
//
//  Created by 调包侠 on 2025/6/20.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXGuard.h"
#import <objc/runtime.h>

@implementation DBXGuard

+ (void)disableClassName:(NSString *)className methods:(NSString *)methods {
    NSArray *methodList = [methods componentsSeparatedByString:@"/"];
    Class cls = NSClassFromString(className);
    
    for (NSString *method in methodList) {
        SEL selector = NSSelectorFromString(method);
        Method targetMethod = class_getInstanceMethod(cls, selector);
        if (!targetMethod) return;
        
        IMP emptyIMP = [self getEmptyIMPForMethod:targetMethod];
        method_setImplementation(targetMethod, emptyIMP);
    }
    
}

+ (IMP)getEmptyIMPForMethod:(Method)method {
    const char *type = method_getTypeEncoding(method);
    
    if (strstr(type, "v")) { // void
        return imp_implementationWithBlock(^(id self) { NSLog(@"被替换了"); });
    } else if (strstr(type, "@")) { // id
        return imp_implementationWithBlock(^(id self) { return nil; });
    } else if (strstr(type, "B")) {
        return imp_implementationWithBlock(^(id self) { return NO; });
    }
    
    return nil;
}


@end
