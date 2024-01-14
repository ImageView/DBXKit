//
//  MySyringInterface.h
//  DBXKit
//
//  Created by asherluo on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXSyringeInterface.h"
#import "DBXSyringe.h"

NS_ASSUME_NONNULL_BEGIN

@class People;
@class Animal;
@interface MySyringInterface : DBXSyringeInterface

- (People *)peopleWithName:(NSString *)name;

- (People *)people;

- (People *)peopleName:(NSString *)name age:(NSNumber *)age;

- (Animal *)dog;
@end

NS_ASSUME_NONNULL_END
