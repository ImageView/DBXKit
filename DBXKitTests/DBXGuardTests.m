//
//  DBXGuardTests.m
//  DBXKitTests
//
//  Created by 罗俊宇 on 2025/6/23.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DBXGuard.h"
#import "Animal.h"
@interface DBXGuardTests : XCTestCase

@property(nonatomic, strong) Animal *dog;

@end

@implementation DBXGuardTests

- (void)setUp {
    self.dog = [[Animal alloc] init];
    [DBXGuard disableClassName:@"Animal" methods:@"eatFood:"];
}

- (void)tearDown {
    
}

- (void)testExample {
    [self.dog eatFood:@"KFC"];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
