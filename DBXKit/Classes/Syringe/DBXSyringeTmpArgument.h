//
//  DBXSyringeTmpArgument.h
//  DBXKit
//
//  Created by asherluo on 2022/9/15.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 临时参数
@interface DBXSyringeTmpArgument : NSObject

// 参数在方法中所在的下标，非invocation中的下标，如initWithName:(NSString *)name中，name下标为0
@property(nonatomic, assign) NSInteger index;

- (instancetype)initWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
