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

@end

@implementation DBXDebounceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
    rule.selector = @selector(testA:);
    rule.target = self;
    rule.debounceInterval = 2;
    rule.model = DBXDebounceModelDebounce;
    [rule apply];
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = UIColor.redColor;
    [button setTitle:@"多次测试" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(testA:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(50, 50, 100, 100);
    [self.view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc] init];
    button1.backgroundColor = UIColor.blueColor;
    [button1 setTitle:@"局部变量测试" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(testB) forControlEvents:UIControlEventTouchUpInside];
    button1.frame = CGRectMake(50, 150, 100, 100);
    [self.view addSubview:button1];
}

- (void)testA:(NSString *)aa {
    NSLog(@"%s", __func__);
}

- (void)testB {
    NSLog(@"%s", __func__);
    
    People *p1 = [[People alloc] init];
    
    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
    rule.selector = @selector(test:);
    rule.target = p1;
    rule.debounceInterval = 2;
    rule.model = DBXDebounceModelFirstOnly;
    [rule apply];
    
    for (int i = 0; i<30; i++) {
        [p1 test:[NSString stringWithFormat:@"hahaha%d",i]];
    }
    NSLog(@"结束了");
}

- (void)testC {
    
}
@end
