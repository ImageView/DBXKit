//
//  MnaDBUIPropertyModel.h
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2024/8/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MnaDBUIPropertyModel : NSObject

// 本属性名字
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *className;
@property(nonatomic, copy) NSString *info;

- (instancetype)initWithPropertyName:(NSString *)name objectCls:(Class)cls;

- (instancetype)initWithIvarName:(NSString *)name ivarClasssName:(NSString *)className;
@end

NS_ASSUME_NONNULL_END
