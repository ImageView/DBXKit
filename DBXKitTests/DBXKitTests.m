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
#import <objc/runtime.h>
#import "DBXCore.h"
#import "UIView+dbx_clickedArea.h"
#import "DBXTrack.h"

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
    DBXConfig *config = [[DBXConfig alloc] init];
    config.debugLogOption = DBXLogOptionLogFunction | DBXLogOptionLogThread;
    config.logOption = DBXLogOptionLogFile | DBXLogOptionLogThread;
    config.closeUnsafeFeatures = NO;
    [DBXCenter initWithConfig:config];
    DBXLog(@"测试日志");
}

- (void)tearDown {
    
}

// 测试DBXDebounceShouldInvote功能
- (void)testShouldInvokeImmediatelyBlock {
    DBXDebounceRule *rule = [self.dog dbx_performSelectorDebounce:@selector(eatFood:) debounceInterval:.2 mode:DBXDebounceModeFirstOnly queue:dispatch_get_global_queue(0, 0) shouldInvokeImmediatelyBlock:^(DBXDebounceInvocation *invocation, NSString *food) {
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
        [self.dog eatFood:@"屎"];
        [self.dog eatFood:@"水"];
        [self.dog eatFood:@"骨头"];
    }
    int c1 = [self.dog countOfFood:@"屎"];
    int c2 = [self.dog countOfFood:@"水"];
    int c3 = [self.dog countOfFood:@"骨头"];

    XCTAssertEqual(c1, 0, @"屎不能吃");
    XCTAssertEqual(c2, testCont, @"水多喝，不限制");
    XCTAssertLessThan(c3, testCont, @"骨头限量吃");
    [rule discard];
}

// 反复打开关闭规则
- (void)testInstanceApplyAndDisCardRepeatedly {
    Animal *cat = [[Animal alloc] init];
    cat.name = @"局部猫咪";
    DBXDebounceRule *rule = [cat dbx_performSelectorDebounce:@selector(eatFood:) debounceInterval:.5 mode:DBXDebounceModeFirstOnly];
    __block BOOL succ = rule ? YES : NO;;
    XCTAssertTrue(succ);
    [cat eatFood:@"food"];
    [cat eatFood:@"food"];
    XCTAssertEqual([cat countOfFood:@"food"], 1, @"开启了规则，应该只吃了1次");
    
    succ = [rule discard];
    XCTAssertTrue(succ);
    [cat eatFood:@"food2"];
    [cat eatFood:@"food2"];
    XCTAssertEqual([cat countOfFood:@"food2"], 2, @"关闭规则，应该吃了2次");
    
    succ = [rule apply];
    XCTAssertTrue(succ);
    XCTestExpectation *ex = [[XCTestExpectation alloc] initWithDescription:@"等待上面的防抖失效"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cat eatFood:@"food3"];
        [cat eatFood:@"food3"];
        XCTAssertEqual([cat countOfFood:@"food3"], 1, @"又打开了规则，应该只能吃1次");
        succ = [rule discard];
        [ex fulfill];
    });
    [self waitForExpectations:@[ex]];
    
    [cat eatFood:@"food4"];
    [cat eatFood:@"food4"];
    XCTAssertEqual([cat countOfFood:@"food4"], 2, @"又关闭了规则，明明吃了2次");
    [rule discard];
}

// 自动注销rule
- (void)testAutoRelease {
    // People注册过之后，生成的__debounce_People子类还在，并且方法被被hook了，这里测试target中被release之后规则是否也被自动注销
    int testCount = 5;
    {
        People *p1 = [[People alloc] init];
        p1.name = @"张三";
        [p1 dbx_performSelectorDebounce:@selector(eatFood:) debounceInterval:0.5 mode:DBXDebounceModeFirstOnly];
        for (int i = 0; i<testCount; i++) {
            [p1 eatFood:@"饭"];
        }
        XCTAssertEqual([p1 countOfFood:@"饭"], 1);
    }
    Class subCls = objc_getClass("_DBXDebounce_People");
    id p2 = [[subCls alloc] init];
    for (int i = 0; i<testCount; i++) {
        [p2 eatFood:@"饭"];
    }
    XCTAssertEqual([p2 countOfFood:@"饭"], testCount, @"rule失效，p2吃”饭”的次数应该跟遍历次数一样才对");
}

// 测试一个类的不同实例对同一个方法添加rule
- (void)testTwoSameRule {
    DBXDebounceRule *rule1 = [self.cat dbx_performSelectorDebounce:@selector(eatFood:) debounceInterval:.5 mode:DBXDebounceModeFirstOnly];
    Animal *jinmao = [[Animal alloc] init];
    jinmao.name = @"金毛";
    DBXDebounceRule *rule2 = [jinmao dbx_performSelectorDebounce:@selector(eatFood:) debounceInterval:.5 mode:DBXDebounceModeFirstOnly];
    int testCount = 5;
    for (int i = 0; i<testCount; i++) {
        [self.dog eatFood:@"狗粮"];
        [self.cat eatFood:@"猫粮"];
        [jinmao eatFood:@"骨头"];
    }
    XCTAssertEqual([self.dog countOfFood:@"狗粮"], testCount, @"规则没有设置到self.dog上，不限量吃");
    XCTAssertEqual([self.cat countOfFood:@"猫粮"], 1, @"self.cat加了规则，应该只吃了1次");
    XCTAssertEqual([jinmao countOfFood:@"骨头"], 1, @"金毛加了规则，应该只吃了1次");
    [rule1 discard];
    
    for (int i = 0; i<testCount; i++) {
        [self.cat eatFood:@"other"];
        [jinmao eatFood:@"other"];
    }
    XCTAssertEqual([self.cat countOfFood:@"other"], testCount, @"self.cat规则去除了，不限量了");
    XCTAssertEqual([jinmao countOfFood:@"other"], 0, @"金毛规则还在，应该只吃了0次");
    
    [rule2 discard];
}

- (void)testClassRule {
    DBXDebounceRule *rule = [People dbx_performClassSelectorDebounce:@selector(contry) debounceInterval:.5 mode:DBXDebounceModeFirstOnly];
    
    int testCount = 5;
    for (int i = 0; i< testCount; i++) {
        [People contry];
    }
    NSArray *rules = [object_getClass(People.class) dbx_allRules];
    
    [rule discard];
}

- (void)testChangeInvocation {
    DBXDebounceRule *rule = [self.dog dbx_performSelectorDebounce:@selector(eatFood:) debounceInterval:.2 mode:DBXDebounceModeFirstOnly queue:dispatch_get_global_queue(0, 0) shouldInvokeImmediatelyBlock:^(DBXDebounceInvocation *invocation, NSString *food) {
        NSString *newFood = @"蔬菜";
        [invocation.invocation setArgument:&newFood atIndex:2];
        return DBXDebounceShouldInvoteInRule;
    }];
    
    [self.dog eatFood:@"肉"];
    XCTAssertEqual([self.dog countOfFood:@"肉"], 0, @"肉换成蔬菜了");
    XCTAssertEqual([self.dog countOfFood:@"蔬菜"], 1, @"肉换成蔬菜了");
    [rule discard];
}

// 测试Deboucne线程安全
- (void)testDeboucneThreadSafe {
    for (int i = 0; i<100; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSObject *obj = [[NSObject alloc] init];
            [obj dbx_performSelectorDebounce:@selector(description) debounceInterval:1 mode:DBXDebounceModeFirstOnly];
        });
    }
    
}

// 测试创建派生类的线程安全问题，由于线程问题比较随机，这里在线程不安全时也需要反复多次调用才可能出现一次crash
- (void)testViewHitTestThreadSafe {
    for (int i = 0; i<300; i++) {
        UIView *view = [[UIView alloc] init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [view dbx_enableExtendedClickedAreaEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        });
    }
    
}

- (void)testTrack {
//    Animal *dog = [Animal new];
    DBXTrackTarget *model = [DBXTrackTarget new];
    model.target = UIViewController.class;
    [DBXTrack dbx_trackTarget:model methodCall:nil];
//    [dog run];
//    [dog eat:@"shit"];
}

@end
