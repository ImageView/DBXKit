//
//  DBXSyringeMethod.h
//  DBXKit
//
//  Created by 调包侠 on 2022//8.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 函数模型
@interface DBXSyringeMethod : NSObject
// 初始化
- (instancetype)initWithSelector:(_Nullable SEL)selector;

// method的sel
@property(nonatomic, assign) SEL selector;

// 根据参数初始化一个invocation对象，用于方法的执行
- (NSInvocation *)createInvocationWithArgums:(NSArray *)argums ofClass:(Class)clazz;

// 添加参数，参数个数要和selector对应上
- (void)addParameter:(id)parameter;

@end

NS_ASSUME_NONNULL_END
