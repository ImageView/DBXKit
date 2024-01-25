//
//  DBXSyringeInterface.h
//  DBXKit
//
//  Created by asherluo on 2022/6/7.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXSyringeInject;
// 注入接口
@interface DBXSyringeInterface : NSObject

// 返回已激活的实例
+ (instancetype)activatedInterface;

- (instancetype)activated;

- (DBXSyringeInject *)injectOfSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
