//
//  DBXSyringViewController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/14.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXSyringViewController.h"
#import "MySyringInterface.h"
#import "Animal.h"
#import "People.h"

@interface DBXSyringViewController ()

@end

@implementation DBXSyringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testSyringe];
}

- (void)testSyringe {
    
    MySyringInterface *interface = [MySyringInterface new];
    interface = [interface activated];
    
    People *p1 = [interface people];
    People *p2 = [interface peopleName:@"asherluo" age:@(18)];
    Animal *dog = p2.pet;
    [dog run];
    
    People *p3 = [interface peopleWithName:@"111"];
    NSLog(@"p1 = %@, p2 = %@  p3=%@", p1,p2,p3);
    NSLog(@"123");
}

@end
