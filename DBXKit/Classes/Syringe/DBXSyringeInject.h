//
//  DBXSyringeInject.h
//  DBXKit
//
//  Created by 调包侠 on 2022/6/8.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXSyringeInject;
@class DBXSyringeMethod;
typedef void(^DBXSyringeInjectBlock)(DBXSyringeInject *inject);

// 注入品，用于生成需要的类
@interface DBXSyringeInject : NSObject

+ (id)injectWithClass:(Class)clazz configuration:(DBXSyringeInjectBlock)config;
// 除了初始化方法要的参数，还需要在初始化完成后设置参数，用这个方法设置
- (void)addPropertyValue:(id)value to:(SEL)selector;
// 要生成的实例的类
@property(nonatomic, assign) Class outPutClass;

// 在Interface中创建本实例的key
@property(nonatomic, strong) NSString *key;

- (void)initOutPutWithSelector:(SEL)selector parames:(void (^)(DBXSyringeMethod *method))paramesBlock;

- (id)initInstanceWithArgs:(NSArray *)args;

@end

NS_ASSUME_NONNULL_END
