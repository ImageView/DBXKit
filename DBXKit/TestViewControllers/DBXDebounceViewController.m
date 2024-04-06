//
//  DBXDebounceViewController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/28.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXDebounceViewController.h"
#import "DBXDebounce.h"
#import "People.h"

@interface DBXDebounceViewController ()

@property(nonatomic, strong) NSArray *list;
@property(nonatomic, strong) Animal *dog;
@property(nonatomic, strong) Animal *cat;

@end

@implementation DBXDebounceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
    rule.selector = @selector(run);
    rule.target = [Animal class];
    rule.debounceInterval = 2;
    rule.model = DBXDebounceModelFirstOnly;
    [rule apply];
    
    self.list = @[@"类防抖测试", @"局部变量防抖测试", @"测试反复注册规则"];
    
    self.dog = [[Animal alloc] init];
    self.dog.name = @"狗狗";
    self.cat = [[Animal alloc] init];
    self.cat.name = @"猫猫www";

    DBXDebounceRule *rule2 = [[DBXDebounceRule alloc] init];
    rule2.selector = @selector(barking);
    rule2.target = self.cat;
    rule2.debounceInterval = 2;
    rule2.model = DBXDebounceModelDebounce;
    [rule2 apply];
}

- (void)classTest {
//    NSLog(@"%s", __func__);
    [self.dog run];
    [self.cat run];

//    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
//    rule.selector = @selector(run);
//    rule.target = [Animal class];
//    rule.debounceInterval = 2;
//    rule.model = DBXDebounceModelDebounce;
//    [rule apply];
}

- (void)instanceTest {
    [self.dog barking];
    [self.cat barking];
//    NSLog(@"%s", __func__);
//    
//    People *p1 = [[People alloc] init];
//    
//    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
//    rule.selector = @selector(test:);
//    rule.target = p1;
//    rule.debounceInterval = 2;
//    rule.model = DBXDebounceModelFirstOnly;
//    [rule apply];
//    
//    for (int i = 0; i<10; i++) {
//        [p1 test:[NSString stringWithFormat:@"hahaha%d",i]];
//    }
//    NSLog(@"结束了");
}

- (void)repeatApply {
    People *p1 = [[People alloc] init];
    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
    rule.selector = @selector(test:);
    rule.target = p1;
    rule.debounceInterval = 2;
    rule.model = DBXDebounceModelFirstOnly;
    [rule apply];
    
    DBXDebounceRule *rule1 = [[DBXDebounceRule alloc] init];
    rule1.selector = @selector(test:);
    rule1.target = p1;
    rule1.debounceInterval = 2;
    rule1.model = DBXDebounceModelFirstOnly;
    [rule1 apply];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.list[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.list[indexPath.row];
    if ([title isEqualToString:@"类防抖测试"]) {
        [self classTest];
    } else if ([title isEqualToString:@"局部变量防抖测试"]) {
        [self instanceTest];
    } else if ([title isEqualToString:@"测试反复注册规则"]) {
        [self repeatApply];
    }
}
@end
