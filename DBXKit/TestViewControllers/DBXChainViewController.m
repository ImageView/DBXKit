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

@interface DBXChainViewController ()

@end

@implementation DBXChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)testChainTask:(id)sender {
    dispatch_queue_t queue = dispatch_queue_create("asherluo", nil);
    
    [[[[self createTaskWithName:@"111"] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        
        DBXChainTask *next = [self createTaskWithName:@"222"];
        NSLog(@"%@完成了任务，下一个任务是%@",task.taskName, next.taskName);
        return next;
    } operate:[[DBXCustomThreadOperate alloc] initWithQueue:queue]] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        if (task.error) {
            return task.error;
        }
        DBXChainTask *next = [self createTaskWithName:@"333"];
        NSLog(@"%@完成了任务，下一个任务是%@",task.taskName, next.taskName);
        return next;
//        return nil;
    } operate:[DBXMainThreadOperate new]] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        DBXChainTask *next = [self createTaskWithName:@"444" sleep:0];
        NSLog(@"%@完成了任务，下一个任务是%@",task.taskName, next.taskName);
        return next;
    }];
}

- (IBAction)testGroup:(id)sender {

    DBXChainTask *task2 = [self createTaskWithName:@"2222"];
    [[DBXChainTask executGroupTasks:@[[self createTaskWithName:@"111" sleep:1], task2, [self createTaskWithName:@"333"]]] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        NSError *error = [DBXChainTask errorOfTask:task2 fromGroupError:task.error];
        NSDictionary *resultDic = task.result;
        NSLog(@"并行任务完成, task=%@,error=%@,result222=%@", task, error,resultDic[[task2 resultKey]]);
        return nil;
    }];
}

- (DBXChainTask *)createTaskWithName:(NSString *)name {
    return [self createTaskWithName:name sleep:1];
}

- (DBXChainTask *)createTaskWithName:(NSString *)name sleep:(int)s {
    DBXChainTask *task = [DBXChainTask chainTask];
    task.taskName = name;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(s);
        bool isSuc = YES;
        if ([task.taskName isEqualToString:@"222"]) {
            isSuc = NO;
        }
        NSLog(@"任务%@结束,详情：%@", name, @(task.hash));
        if (isSuc) {
            [task setResult:@{@"res":@"succ"}];
        } else {
            [task setError:[NSError errorWithDomain:[NSString stringWithFormat:@"%@ failed",task.taskName ] code:-1 userInfo:nil]];
        }
    });
    return task;
}

@end
