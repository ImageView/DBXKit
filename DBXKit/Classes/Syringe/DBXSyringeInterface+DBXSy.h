//
//  DBXSyringeInterface+DBXSy.h
//  DBXKit
//
//  Created by 调包侠 on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXSyringeInterface (DBXSy)
// 读取当前的注入的method
- (NSSet *)injectsSelects;

// 是否是排除掉的方法
+ (BOOL)isExcludeSelector:(SEL)selector;
// DBXSyringeInterface排除的类型集合，新增的方法需要在这里添加
+ (NSMutableSet *)excludeMethodSet;

@end

NS_ASSUME_NONNULL_END
