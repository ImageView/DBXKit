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

@property(nonatomic, strong) Animal *dog;
@property(nonatomic, strong) Animal *cat;

@end

@implementation DBXDebounceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
    rule.selector = @selector(run);
    rule.target = [Animal class];
    rule.debounceInterval = 2;
    rule.model = DBXDebounceModelFirstOnly;
    [rule apply];
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = UIColor.redColor;
    [button setTitle:@"类防抖测试" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(classTest) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(50, 50, 200, 100);
    [self.view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc] init];
    button1.backgroundColor = UIColor.blueColor;
    [button1 setTitle:@"局部变量防抖测试" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(instanceTest) forControlEvents:UIControlEventTouchUpInside];
    button1.frame = CGRectMake(50, 150, 200, 100);
    [self.view addSubview:button1];
    
    [DBXDebounce sharedInstance].debug = YES;
    
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

- (void)testC {
    
}
@end
