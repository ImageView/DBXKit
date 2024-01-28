//
//  DBXDebounceViewController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/28.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXDebounceViewController.h"
#import "DBXDebounce.h"

@interface DBXDebounceViewController ()

@end

@implementation DBXDebounceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DBXDebounceRule *rule = [[DBXDebounceRule alloc] init];
    rule.selector = @selector(testA:);
    rule.target = self;
    rule.debounceInterval = 2;
    [rule apply];
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = UIColor.redColor;
    [button addTarget:self action:@selector(testA:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(50, 50, 100, 100);
    [self.view addSubview:button];
}

- (void)testA:(NSString *)aa {
    NSLog(@"%@", aa);
}
@end
