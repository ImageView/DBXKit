//
//  DBXDebounceViewController.m
//  DBXKit
//
//  Created by 调包侠 on 2024/1/28.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXDebounceViewController.h"
#import "DBXDebounce.h"
#import "People.h"

@interface DBXDebounceViewController ()

@property(nonatomic, strong) NSArray *list;
@property(nonatomic, strong) Animal *dog;
@property(nonatomic, strong) Animal *cat;

@property(nonatomic, strong) DBXDebounceRule *instanceRule;
@property(nonatomic, strong) DBXDebounceRule *classRule;

@end

@implementation DBXDebounceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.list = @[@"注册规则", @"类防抖测试", @"局部变量防抖测试", @"测试反复注册规则", @"注销规则", @"便捷执行"];
    
    self.dog = [[Animal alloc] init];
    self.dog.name = @"狗狗";
    self.cat = [[Animal alloc] init];
    self.cat.name = @"猫猫www";
}

- (void)classTest {
//    NSLog(@"%s", __func__);
    [self.dog run];
    [self.cat run];

//    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
//    rule.selector = @selector(run);
//    rule.target = [Animal class];
//    rule.debounceInterval = 2;
//    rule.model = DBXDebounceModeDebounce;
//    [rule apply];
}

- (void)instanceTest {
    [self.dog eat:@"骨头"];
//    [self.dog eat:@"水"];
//    [self.dog eat:@"屎"];
//    [self.dog barking];
//    [self.cat barking];
//    NSLog(@"%s", __func__);
//    
//    People *p1 = [[People alloc] init];
//    
//    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
//    rule.selector = @selector(test:);
//    rule.target = p1;
//    rule.debounceInterval = 2;
//    rule.model = DBXDebounceModeFirstOnly;
//    [rule apply];
//    
//    for (int i = 0; i<10; i++) {
//        [p1 test:[NSString stringWithFormat:@"hahaha%d",i]];
//    }
//    NSLog(@"结束了");
}

- (void)applyRule {
//    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
//    rule.selector = @selector(run);
//    rule.target = [Animal class];
//    rule.debounceInterval = 2;
//    rule.model = DBXDebounceModeFirstOnly;
//    [rule apply];
//    self.classRule = rule;
    if (!self.instanceRule) {
        DBXDebounceRule *eatRule = [[DBXDebounceRule alloc] initWithTarget:self.dog selector:@selector(eat:) debounceInterval:2];
        eatRule.model = DBXDebounceModeFirstOnly;
        self.instanceRule = eatRule;
    }
   
//    eatRule.shouldInvokeImmediatelyBlock = ^DBXDebounceShouldInvote (DBXDebounceRule *rule, NSString *food) {
//        if ([food isEqualToString:@"水"]) {
//            return DBXDebounceShouldInvoteIgnoreRule;
//        }
//        if ([food isEqualToString:@"屎"]) {
//            return DBXDebounceShouldNotInvote;
//        }
//        return DBXDebounceShouldInvoteInRule;
//    };
    [self.instanceRule apply];

//    DBXDebounceRule *rule2 = [[DBXDebounceRule alloc] initWithTarget:self.cat selector:@selector(barking) debounceInterval:2];
//    rule2.model = DBXDebounceModeDebounce;
//    [rule2 apply];
//    self.instanceRule = rule2;
}

- (void)discardRule {
    [self.classRule discard];
    [self.instanceRule discard];
}

- (void)objectRule {
    Animal *dog = [[Animal alloc] init];
    [dog dbx_performSelectorDebounce:@selector(eat:) debounceInterval:2 mode:DBXDebounceModeDebounce queue:nil shouldInvokeImmediatelyBlock:^(DBXDebounceInvocation *invocation, NSString *food) {
        if ([food isEqualToString:@"屎"]) {
            return DBXDebounceShouldNotInvote;
        }
        return DBXDebounceShouldInvoteInRule;
    }];
    
    [dog eat:@"肉"];
    [dog eat:@"肉"];
    [dog eat:@"屎"];
    [dog eat:@"屎"];
}

- (void)repeatApply {
    People *p1 = [[People alloc] init];
    DBXDebounceRule *rule = [[DBXDebounceRule alloc] initWithTarget:p1 selector:@selector(test:) debounceInterval:2];
    rule.model = DBXDebounceModeFirstOnly;
    [rule apply];
    
    DBXDebounceRule *rule1 = [[DBXDebounceRule alloc] initWithTarget:p1 selector:@selector(test:) debounceInterval:2];
    rule1.model = DBXDebounceModeFirstOnly;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = self.list[indexPath.row];
    if ([title isEqualToString:@"类防抖测试"]) {
        [self classTest];
    } else if ([title isEqualToString:@"局部变量防抖测试"]) {
        [self instanceTest];
    } else if ([title isEqualToString:@"测试反复注册规则"]) {
        [self repeatApply];
    } else if ([title isEqualToString:@"注册规则"]) {
        [self applyRule];
    } else if ([title isEqualToString:@"注销规则"]) {
        [self discardRule];
    } else if ([title isEqualToString:@"便捷执行"]) {
        [self objectRule];
    }
}
@end
