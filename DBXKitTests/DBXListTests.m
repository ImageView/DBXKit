//
//  DBXListTests.m
//  DBXKitTests
//
//  Created by 罗俊宇 on 2025/8/4.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DBXList.h"
#import "People.h"

@interface DBXListTests : XCTestCase

@end

@implementation DBXListTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDiffInsert {
    NSArray *a = @[@"0", @"1", @"2", @"3", @"4"];
    NSArray *b = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6"];
    DBXListDiffIndexResult *set = [DBXListDiff listDiffingWithOldArray:a newArray:b option:DBXListDiffOptionListDiffEquality];
    [set.inserts enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSLog(@"插入的索引: %lu", (unsigned long)idx);
    }];
    XCTAssertTrue(set.deletes.count == 0);
    XCTAssertTrue(set.updates.count == 0);
    XCTAssertTrue(set.moves.count == 0);
}

- (void)testDiffDelete {
    NSArray *a = @[@"0", @"1", @"2", @"3", @"4"];
    NSArray *b = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6"];
    DBXListDiffIndexResult *set = [DBXListDiff listDiffingWithOldArray:b newArray:a option:DBXListDiffOptionListDiffEquality];
    [set.deletes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSLog(@"删除索引: %lu", (unsigned long)idx);
    }];
    XCTAssertTrue(set.inserts.count == 0);
    XCTAssertTrue(set.updates.count == 0);
    XCTAssertTrue(set.moves.count == 0);
}

- (void)testDiffUpdate {
    People *a = [[People alloc] initWithNum:@0 name:@"asher" size:1];
    People *b = [[People alloc] initWithNum:@1 name:@"asher1" size:1];
    People *c = [[People alloc] initWithNum:@2 name:@"asher2" size:1];
    People *d = [[People alloc] initWithNum:@3 name:@"asher3" size:1];
    NSArray *one = @[a,b,c,d];
    
    People *e = [[People alloc] initWithNum:@3 name:@"asher4" size:1];
    People *f = [[People alloc] initWithNum:@2 name:@"asher2" size:1];
    NSArray *two = @[a,b,f,e];
    
    DBXListDiffIndexResult *set = [DBXListDiff listDiffingWithOldArray:one newArray:two option:DBXListDiffOptionListDiffEquality];
    [set.updates enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSLog(@"按照diff的定义比对的变更的索引: %lu", (unsigned long)idx);
    }];
    
    DBXListDiffIndexResult *set2 = [DBXListDiff listDiffingWithOldArray:one newArray:two option:DBXListDiffOptionPointer];
    [set2.updates enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSLog(@"按照指针地址比对的变更的索引: %lu", (unsigned long)idx);
    }];
}

- (void)testDiffMove {
    People *a = [[People alloc] initWithNum:@0 name:@"asher" size:1];
    People *b = [[People alloc] initWithNum:@1 name:@"asher1" size:1];
    People *c = [[People alloc] initWithNum:@2 name:@"asher2" size:1];
    People *d = [[People alloc] initWithNum:@3 name:@"asher3" size:1];
    
    NSArray *one = @[a,b,c,d];
    NSArray *two = @[a,c,d,b];
    
    DBXListDiffIndexResult *set = [DBXListDiff listDiffingWithOldArray:one newArray:two option:DBXListDiffOptionListDiffEquality];
    [set.moves enumerateObjectsUsingBlock:^(DBXListMoveIndex * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"移动的索引  从%d移到%d", (int)obj.from, (int)obj.to);
    }];
    XCTAssertTrue(set.inserts.count == 0);
    XCTAssertTrue(set.updates.count == 0);
    XCTAssertTrue(set.deletes.count == 0);
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
