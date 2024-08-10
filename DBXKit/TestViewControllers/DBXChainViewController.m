//
//  DBXChainViewController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2023/12/30.
//  Copyright © 2023 DBX. All rights reserved.
//

#import "DBXChainViewController.h"
#import "DBXChainTask.h"
#import "DBXOperate.h"
#import "DBXTrack.h"
@interface DBXChainViewController ()

@end

@implementation DBXChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DBXTrack dbx_trackTarget:self.class condition:^BOOL(SEL  _Nonnull selector) {
        return YES;
    } before:^(id  _Nonnull target, SEL  _Nonnull sel, NSArray * _Nonnull args) {
        NSLog(@"before [%@ %@ %@]",[target class], NSStringFromSelector(sel), args);
    } after:^(id  _Nonnull target, SEL  _Nonnull sel, NSArray * _Nonnull args) {
        NSLog(@"after [%@ %@ %@]",[target class], NSStringFromSelector(sel), args);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (IBAction)testTimeoutTask:(id)sender {
    DBXChainTask *task = [self createTaskWithName:@"abc" sleep:5];
    task.timeOutInterval = 3;
    [task thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        if (task.error) {
            NSLog(@"%@%@",task.taskName,task.error.localizedDescription);
            return task.error;
        }
        return [self createTaskWithName:@"def"];
    }];
}

- (IBAction)testChainTask:(id)sender {
    dispatch_queue_t queue = dispatch_queue_create("asherluo", nil);
    [[[[self createTaskWithName:@"111"] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        DBXChainTask *next = [self createTaskWithName:@"222"];
        return next;
    } ] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        if (task.error) {
            return task.error;
        }
        DBXChainTask *next = [self createTaskWithName:@"333"];
        return next;
    } ] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        DBXChainTask *next = [self createTaskWithName:@"444" sleep:0];
        return next;
    }];
}

- (IBAction)testGroup:(id)sender {
    DBXChainTask *task1 = [self createTaskWithName:@"111" sleep:1 shouldSuccess:NO];
    task1.tag = 110;
    DBXChainTask *task2 = [self createTaskWithName:@"2222" sleep:1 shouldSuccess:NO];
    
    [[DBXChainTask executGroupTasks:@[task1, task2, [self createTaskWithName:@"333"]]] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        
        NSError *error = [task.error dbx_errorWithTaskTag:110];
        NSError *error222 = [task.error dbx_errorWithTask:task2];

        NSDictionary *resultDic = task.result;
        NSLog(@"并行任务完成, task=%@,error=%@,result222=%@", task, error,resultDic[[task2 resultKey]]);
        return nil;
    }];
}

- (DBXChainTask *)createTaskWithName:(NSString *)name {
    return [self createTaskWithName:name sleep:1];
}

- (DBXChainTask *)createTaskWithName:(NSString *)name sleep:(int)s {
    return [self createTaskWithName:name sleep:s shouldSuccess:YES];
}

- (DBXChainTask *)createTaskWithName:(NSString *)name sleep:(int)s shouldSuccess:(BOOL)succ {
    DBXChainTask *task = [DBXChainTask chainTask];
    task.taskName = name;
//    QMUIAlertController *alert = [QMUIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"任务%@正在执行", name] message:nil preferredStyle:QMUIAlertControllerStyleAlert];
//    [alert addAction:[QMUIAlertAction actionWithTitle:@"标记成功" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
//        [task setResult:@{@"res":@"succ"}];
//    }]];
//    [alert addAction:[QMUIAlertAction actionWithTitle:@"标记失败" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
//        [task setError:[NSError errorWithDomain:[NSString stringWithFormat:@"%@ failed",task.taskName ] code:-1 userInfo:nil]];
//    }]];
//    [alert showWithAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(s * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"任务%@结束,详情：%@", name, @(task.hash));
        if (succ) {
            [task setResult:@{@"res":@"succ"}];
        } else {
            [task setError:[NSError errorWithDomain:[NSString stringWithFormat:@"%@ failed",task.taskName ] code:-1 userInfo:nil]];
        }
    });
    return task;
}

@end
