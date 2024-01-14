//
//  MySyringInterface.m
//  DBXKit
//
//  Created by asherluo on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "MySyringInterface.h"
#import "People.h"

@implementation MySyringInterface

- (People *)peopleWithName:(NSString *)name {
    return [DBXSyringeInject injectWithClass:[People class] configuration:^(DBXSyringeInject * _Nonnull inject) {
        
    }];
}

- (People *)people {
    return [DBXSyringeInject injectWithClass:[People class] configuration:^(DBXSyringeInject * _Nonnull inject) {
        
    }];
}

- (People *)peopleName:(NSString *)name age:(NSNumber *)age {
    return [DBXSyringeInject injectWithClass:[People class] configuration:^(DBXSyringeInject * _Nonnull inject) {
        [inject initOutPutWithSelector:@selector(initWithNum:name:size:) parames:^(DBXSyringeMethod *method) {
//            [method addParameter:age];
            [method addParameter:@(2234)];
            [method addParameter:name];
            [method addParameter:@(11.0)];
        }];
        [inject addPropertyValue:@"深圳" to:@selector(city)];
        [inject addPropertyValue:@(11111112) to:@selector(idnum)];
        [inject addPropertyValue:self.dog to:@selector(pet)];
    }];
}

- (Animal *)dog {
    return [DBXSyringeInject injectWithClass:[Animal class] configuration:^(DBXSyringeInject * _Nonnull inject) {
        
    }];
}

@end
