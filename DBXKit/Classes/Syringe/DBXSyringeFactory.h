//
//  DBXSyringeFactory.h
//  DBXKit
//
//  Created by 调包侠 on 2022/6/7.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXSyringeInject;
@class DBXSyringeInterface;
// 用来生成指定类的的工厂
@interface DBXSyringeFactory : NSObject

// 本factory对应的interface实例
@property(nonatomic, strong) DBXSyringeInterface *interface;

@end

NS_ASSUME_NONNULL_END
