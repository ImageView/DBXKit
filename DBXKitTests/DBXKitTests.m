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
#import "People.h"

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

- (void)testShouldInvokeImmediatelyBlock {
    [self.dog dbx_performSelectorDebounce:@selector(addEat:) debounceInterval:.2 mode:DBXDebounceModeFirstOnly queue:dispatch_get_global_queue(0, 0) shouldInvokeImmediatelyBlock:^(DBXDebounceRule *rule, NSString *food) {
        if ([food isEqualToString:@"屎"]) {
            return DBXDebounceShouldNotInvote;
        }
        if ([food isEqualToString:@"水"]) {
            return DBXDebounceShouldInvoteIgnoreRule;
        }
        return DBXDebounceShouldInvoteInRule;
    }];
    
    int testCont = 10;
    for (int i = 0; i<testCont; i++) {
        [self.dog addEat:@"屎"];
        [self.dog addEat:@"水"];
        [self.dog addEat:@"骨头"];
    }
    int c1 = [self.dog countOfFood:@"屎"];
    int c2 = [self.dog countOfFood:@"水"];
    int c3 = [self.dog countOfFood:@"骨头"];

    XCTAssertEqual(c1, 0, @"屎应该没吃过");
    XCTAssertEqual(c2, testCont, @"水多喝，不限制");
    XCTAssertLessThan(c3, testCont, @"骨头限量吃");
}

- (void)testInstanceApplyAndDisCardRepeatedly {
    Animal *cat = [[Animal alloc] init];
    cat.name = @"局部猫咪";
    DBXDebounceRule *rule = [cat dbx_performSelectorDebounce:@selector(addEat:) debounceInterval:.5 mode:DBXDebounceModeFirstOnly];
    __block BOOL succ = rule ? YES : NO;;
    XCTAssertTrue(succ);
    [cat addEat:@"food"];
    [cat addEat:@"food"];
    XCTAssertEqual([cat countOfFood:@"food"], 1);
    
    succ = [rule discard];
    XCTAssertTrue(succ);
    [cat addEat:@"food2"];
    [cat addEat:@"food2"];
    XCTAssertEqual([cat countOfFood:@"food2"], 2);
    
    succ = [rule apply];
    XCTAssertTrue(succ);
    XCTestExpectation *ex = [[XCTestExpectation alloc] initWithDescription:@"等待防抖时效"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cat addEat:@"food3"];
        [cat addEat:@"food3"];
        XCTAssertEqual([cat countOfFood:@"food3"], 1);
        succ = [rule discard];
        [ex fulfill];
    });
    [self waitForExpectations:@[ex]];
    
    [cat addEat:@"food4"];
    [cat addEat:@"food4"];
    XCTAssertEqual([cat countOfFood:@"food4"], 2);
}

// 自动注销rule
- (void)testAutoRelease {
    // People注册过之后，生成的__debounce_People子类还在，并且方法被被hook了，这里测试target中被release之后规则是否也被自动注销
    int testCount = 10;
    {
        People *p1 = [[People alloc] init];
        p1.name = @"张三";
        [p1 dbx_performSelectorDebounce:@selector(addEat:) debounceInterval:0.5 mode:DBXDebounceModeFirstOnly];
        for (int i = 0; i<testCount; i++) {
            [p1 addEat:@"饭"];
        }
        XCTAssertEqual([p1 countOfFood:@"饭"], 1);
    }
    Class subCls = NSClassFromString(@"_DBXDebounce_People");
    id p2 = [[subCls alloc] init];
    for (int i = 0; i<testCount; i++) {
        [p2 addEat:@"饭"];
    }
    XCTAssertEqual([p2 countOfFood:@"饭"], testCount, @"rule失效，p2吃”饭”的次数应该跟遍历次数一样才对");
}

@end
