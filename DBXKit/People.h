//
//  People.h
//  DBXKit
//
//  Created by asherluo on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animal.h"

NS_ASSUME_NONNULL_BEGIN

@interface People : Animal

@property(nonatomic, assign) NSInteger idnum;
@property(nonatomic, strong) NSString *city;

@property(nonatomic, strong) Animal *pet;

- (instancetype)initWithNum:(NSNumber *)num;

- (instancetype)initWithNum:(NSNumber *)num name:(NSString *)name size:(float)size;

- (void)test:(NSString *)test;

@end

NS_ASSUME_NONNULL_END
