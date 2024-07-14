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
    int c1 = [cat countOfFood:@"food"];
    XCTAssertEqual(c1, 1);
    
    succ = [rule discard];
    XCTAssertTrue(succ);
    [cat addEat:@"food2"];
    [cat addEat:@"food2"];
    int c2 = [cat countOfFood:@"food2"];
    XCTAssertEqual(c2, 2);
    
    succ = [rule apply];
    XCTAssertTrue(succ);
    XCTestExpectation *ex = [[XCTestExpectation alloc] initWithDescription:@"等待防抖时效"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cat addEat:@"food3"];
        [cat addEat:@"food3"];
        int c3 = [cat countOfFood:@"food3"];
        XCTAssertEqual(c3, 1);
        succ = [rule discard];
        [ex fulfill];
    });
    [self waitForExpectations:@[ex]];
    
    [cat addEat:@"food4"];
    [cat addEat:@"food4"];
    int c4 = [cat countOfFood:@"food4"];
    XCTAssertEqual(c4, 2);
}

@end
