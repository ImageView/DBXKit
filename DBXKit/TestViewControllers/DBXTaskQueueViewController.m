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

@property(nonatomic, strong) NSArray *dataList;

@property(nonatomic, strong) DBXTaskQueue *taskQueue;
@end

@implementation DBXTaskQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataList = @[@[@"遛娃", @"散步", @"吃饭", @"打游戏", @"睡觉"], @[@"执行任务",@"执行2个任务",@"暂停任务"]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.taskQueue = [[DBXTaskQueue alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataList[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSArray *array = self.dataList[indexPath.section];
    cell.textLabel.text = array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataList[indexPath.section];
    NSString *text = array[indexPath.row];
    if (indexPath.section == 0) {
        [self.taskQueue addTask:text taskFunc:^(id  _Nonnull task, void (^ _Nonnull taskFinished)(NSError *)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                taskFinished(nil);
            });
        }];
    } else {
        if ([text isEqualToString:@"执行任务"]) {
            [self.taskQueue performTask];
        } else if ([text isEqualToString:@"暂停任务"]) {
            [self.taskQueue suspendTask];
        } else if ([text isEqualToString:@"执行2个任务"]) {
            [self.taskQueue performTaskSynchCount:2];
//            [self.taskQueue performTaskSynchCount:2];
        }
    }
    
}

@end
