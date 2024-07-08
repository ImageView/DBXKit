//
//  DBXKitTests.m
//  DBXKitTests
//
//  Created by 罗俊宇 on 2024/7/5.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DBXDebounce.h"
#import "Animal.h"

@interface DBXKitTests : XCTestCase

@property(nonatomic, strong) Animal *dog;
@property(nonatomic, strong) Animal *cat;

@end

@implementation DBXKitTests

- (void)setUp {
    self.dog = [[Animal alloc] init];
    self.dog.name = @"狗狗";
    self.cat = [[Animal alloc] init];
    self.cat.name = @"猫咪";
}

- (void)tearDown {
    
}

- (void)testDogRun {
    DBXDebounceRule *rule2 = [[DBXDebounceRule alloc] init];
    rule2.selector = @selector(run);
    rule2.target = self.dog;
    rule2.debounceInterval = 2;
    rule2.model = DBXDebounceModelFirstOnly;
    [rule2 apply];
    
    [self.dog run];
    [self.dog run];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
