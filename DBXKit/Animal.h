//
//  Animal.h
//  DBXKit
//
//  Created by asherluo on 2023/1/27.
//  Copyright © 2023 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Animal : NSObject
@property(nonatomic, strong) NSString *name;

@property(nonatomic, assign) NSInteger eatCount;

- (void)eatFood:(NSString *)food;
- (int)countOfFood:(NSString *)food;
- (void)eat:(NSString *)food;
- (void)run;
- (void)testNumber:(int)num;
- (void)barking;
@end

NS_ASSUME_NONNULL_END
