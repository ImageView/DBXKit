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

- (void)testApplyAndDisCardRepeatedly {
    DBXDebounceRule *rule = [[DBXDebounceRule alloc] initWithTarget:self.dog selector:@selector(run) debounceInterval:2];
    rule.model = DBXDebounceModeFirstOnly;
    __block BOOL succ = [rule apply];
    NSLog(@"step1 注册规则(%@)，执行2次run", succ?@"success":@"fail");
    [self.dog run];
    [self.dog run];
    succ = [rule discard];
    NSLog(@"step2 注销规则(%@)，执行2次run", succ?@"success":@"fail");
    [self.dog run];
    [self.dog run];
    succ = [rule apply];
    XCTestExpectation *ex = [[XCTestExpectation alloc] initWithDescription:@"yanshi"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"step3 再次注册规则(%@)，开始执行2次run", succ?@"success":@"fail");
        [self.dog run];
        [self.dog run];
        succ = [rule discard];
        [ex fulfill];
    });
    [self waitForExpectations:@[ex]];
    NSLog(@"step4 再次注销规则(%@)，开始执行2次run", succ?@"success":@"fail");
    [self.dog run];
    [self.dog run];
    NSLog(@"finish");
}

@end
