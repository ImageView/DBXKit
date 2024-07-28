//
//  MnaDBHelper.h
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/11/14.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// runtime辅助工具
@interface MnaDBHelper : NSObject

+ (UIImage *)imageWithName:(NSString *)name;

+ (NSArray *)getIvarList:(Class)cls;

// name<pptClass>@p
+ (NSArray *)getProperties:(Class)cls;

+ (NSString *)getPropertyClass:(NSString *)property inClass:(Class)class;

+ (void)showShareActivityWithItems:(NSArray *)items;

+ (void)showMessage:(NSString *)message inVC:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
