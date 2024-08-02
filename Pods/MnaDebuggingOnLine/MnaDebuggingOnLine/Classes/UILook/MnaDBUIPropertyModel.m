//
//  MnaDBUIPropertyModel.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2024/8/1.
//

#import "MnaDBUIPropertyModel.h"
#import "MnaDBHelper.h"

@implementation MnaDBUIPropertyModel

- (instancetype)initWithPropertyName:(NSString *)name objectCls:(Class)cls
{
    self = [super init];
    if (self) {
        _name = name;
        _className = [MnaDBHelper getPropertyClass:name inClass:cls];
        if (_className) {
            _info = [NSString stringWithFormat:@"%@<%@>(property)", _name, _className];
        } else {
            _info = [NSString stringWithFormat:@"%@(property)", _name];
        }
    }
    return self;
}

- (instancetype)initWithIvarName:(NSString *)name ivarClasssName:(NSString *)className
{
    self = [super init];
    if (self) {
        _name = name;
        _className = className;
        if (_className) {
            _info = [NSString stringWithFormat:@"%@<%@>(ivar)", _name, _className];
        } else {
            _info = [NSString stringWithFormat:@"%@(ivar)", _name];
        }
    }
    return self;
}

@end
