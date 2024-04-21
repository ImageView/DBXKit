//
//  DBXTaskQueueViewController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/21.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXTaskQueueViewController.h"
#import "DBXTaskQueueManager.h"

@interface DBXTaskQueueViewController ()

@property(nonatomic, strong) NSMutableArray *dataList;

@property(nonatomic, strong) DBXTaskQueue *taskQueue;
@end

@implementation DBXTaskQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataList = @[@"遛娃", @"散步", @"吃饭", @"打游戏", @"睡觉", @"执行任务",@"暂停任务"].mutableCopy;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.taskQueue = [[DBXTaskQueue alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.dataList[indexPath.row];
    if ([text isEqualToString:@"执行任务"]) {
        [self.taskQueue performTask];
    } else if ([text isEqualToString:@"暂停任务"]) {
        [self.taskQueue suspendTask];
    } else {
        [self.taskQueue addTask:text taskFunc:^(id  _Nonnull task, void (^ _Nonnull taskFinished)(NSError *)) {
            NSLog(@"开始%@", task);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"结束%@", task);
                taskFinished(nil);
            });
        }];
    }
}

@end
