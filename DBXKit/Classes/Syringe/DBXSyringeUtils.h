//
//  DBXSyringeUtils.h
//  DBXKit
//
//  Created by asherluo on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBXSyringeFactory;
@class DBXSyringeInterface;

// 工具类
@interface DBXSyringeUtils : NSObject

/// 读取类的所有方法，（从clazz到clazz的某一个父类为止）
/// @param clazz 当前的类
/// @param superClazz clazz的某一层父类，读到superClazz后停止，
///                   若为nil，则直接只读clazz的方法
+ (NSSet *)methodsOfClassFrom:(_Nonnull Class)clazz toSuperClass:(_Nullable Class)superClazz;

// 默认的签名
+ (NSMethodSignature *)defaultSignatureForSelector:(SEL)selector;

// 是否是支持的参数类型
+ (BOOL)validArgumentType:(const char *)argType;

//  读取invocation的参数
+ (NSArray *)getArgumesFromInvocation:(NSInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
