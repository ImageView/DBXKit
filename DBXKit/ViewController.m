//
//  ViewController.m
//  DBXKit
//
//  Created by DBX on 2021/7/4.
//

#import "ViewController.h"
#import "NSDictionary+dbx_valuePath.h"
#import "NSObject+dbx_modelValue.h"
#import "MnaLabelsView.h"
#import <QMUIKit/QMUIKit.h>
#import "DBXAutoReport.h"
#import "TextAutoReportImpl.h"
#import "MnaTaskTimerManager.h"
#import "DBXChainTask.h"
#import "DBXOperate.h"

@interface ViewController ()<MnaLabelsViewDelegate, MnaLabelsViewUIDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (nonatomic, strong) MnaLabelsView *labelsView;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *butView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property(nonatomic, strong) TextAutoReportImpl *impl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.labelsView];
    self.labelsView.frame = CGRectMake(20, 50, 200, 40);
    self.labelsView.labelsArray = @[@"texticonbig",@"texticon",@"texticon1"];
    self.labelsView.accessoryPadding = ^UIImage * _Nonnull(NSInteger index) {
        return [UIImage imageNamed:@"tag_master"];
    };
    self.labelsView.imageSetter = ^(UIImageView * _Nonnull imageView, NSString * _Nonnull imgContent) {
        imageView.image = [UIImage imageNamed:imgContent];
    };
//    NSMutableArray *arr = [NSMutableArray array];
//    for (int i = 0; i<3; i++) {
//        NSAttributedString *att = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"哈哈%d",i] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:40], NSForegroundColorAttributeName : [UIColor redColor]}];
//        [arr addObject:att];
//    }
//    self.labelsView.labelsArray = arr;
    
    
    [[DBXAutoReportManager sharedInstance] enableAutoReport];
    [[DBXAutoReportManager sharedInstance] setReportConfig:@{
        @"ViewController_clickedButton:" : @{@"title" : @"234",@"icon" : @"abc.jpg"},
//        @"ViewController/UIView/UIView[01]/UIButton[1]" : @{@"title" : @"234",@"icon" : @"abc.jpg"}
        @"ViewController_clickedImageView:" : @{@"title": @"点击了绿色图片"},
        @"ViewController_clickedButtonInCell:":@{@"111" : @"123"}
    }];
    [DBXAutoReportManager sharedInstance].impl = self.impl;
    
    self.button1.dbx_reportID = @"2341";
    
    [self.button1 addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.butView addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2.superview bringSubviewToFront:self.button2];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"abc"];
    
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedImageView:)]];
    
//    [self testTaskManager];
}

- (void)testTaskManager {
    [[MnaTaskTimerManager sharedInstance] addCycleTask:^{
        NSLog(@"testTaskManager");
    } timeInterval:3 runCount:10 threadMode:MnaThreadModeMain];
}

- (void)testChain {
    
}

- (void)testChainTask {
    dispatch_queue_t queue = dispatch_queue_create("asherluo", nil);
    
    [[[[self createTaskWithName:@"111"] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        DBXChainTask *next = [self createTaskWithName:@"222"];
        NSLog(@"%@完成了任务，下一个任务是%@",task.taskName, next.taskName);
        return next;
    } operate:[[DBXCustomThreadOperate alloc] initWithQueue:queue]] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        DBXChainTask *next = [self createTaskWithName:@"333"];
        NSLog(@"%@完成了任务，下一个任务是%@",task.taskName, next.taskName);
//        return next;
        return nil;
    } operate:[DBXMainThreadOperate new]] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        DBXChainTask *next = [self createTaskWithName:@"444" sleep:0];
        NSLog(@"%@完成了任务，下一个任务是%@",task.taskName, next.taskName);
        return next;
    }];
}

- (void)testGroupChainTask {
    DBXChainTask *task2 = [self createTaskWithName:@"222"];
    [[DBXChainTask executGroupTasks:@[[self createTaskWithName:@"111" sleep:1], task2, [self createTaskWithName:@"333"]]] thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
        NSError *error = [DBXChainTask errorOfTask:task2 fromGroupError:task.error];
        NSLog(@"并行任务完成, task=%@,error=%@", task, error);
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

- (IBAction)clickedButton2:(id)sender {
    [self testChainTask];
}

- (void)clickedButton:(UIButton *)sender
{
    [self testGroupChainTask];
}

- (void)clickedButtonInCell:(UIButton *)sender
{
    NSLog(@"%s", __func__);
}

- (void)clickedImageView:(UITapGestureRecognizer *)tapGes {
    NSLog(@"%s", __func__);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"abc" forIndexPath:indexPath];
    
    UIButton *button = [cell viewWithTag:101];
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor systemPinkColor];
        [button addTarget:self action:@selector(clickedButtonInCell:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(200, 0, 50, 40);
        [cell addSubview:button];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    return cell;
}

#pragma mark - MnaLabelsViewUIDelegate
- (void)labelsView:(MnaLabelsView *)labelsView itemCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {
    cell.backgroundColor = [UIColor qmui_colorWithHexString:@"#11444F"];
//    [cell setValue:RGBHex(0x52B4BB) forKeyPath:@"textColor"];

    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 2;
}

//- (CGSize)labelsView:(MnaLabelsView *)labelsView sizeForItemAtIndex:(NSInteger)index {
//    if (index == 0) {
//        return CGSizeMake(50, 14);
//    } else {
//        return CGSizeMake(32, 14);
//    }
//}

- (void)labelsView:(MnaLabelsView *)labelsView didSelectItemAtIndex:(NSInteger)index {
    NSDictionary *textDic = @{
        @"11" : @{
            @"22" : @"啊哈哈哈",
        }
    };
    NSString *a = [textDic dbx_valueForKeyPath:@"11.22" limitedClass:[NSNumber class]];
    NSString *b = [textDic dbx_valueForKeyPath:@"11.22"];

    NSLog(@"a = %@, b = %@", a, b);
}

- (MnaLabelsView *)labelsView {
    if (!_labelsView) {
        _labelsView = [[MnaLabelsView alloc] initWithStyle:MnaLabelsStyleText];
        _labelsView.itemTextColor = [UIColor qmui_colorWithHexString:@"#00B6BD"];
        _labelsView.textFont = [UIFont systemFontOfSize:11];
        _labelsView.delegate = self;
        _labelsView.UIDelegate = self;
        _labelsView.userInteractionEnabled = YES;
//        _labelsView.itemSize = CGSizeMake(32, 14);
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_labelsView.collectionView.collectionViewLayout;
        if ([layout isKindOfClass:[UICollectionViewFlowLayout class]]) {
            layout.minimumLineSpacing = 4;
        }
    }
    return _labelsView;
}

- (TextAutoReportImpl *)impl {
    if (!_impl) {
        _impl = [[TextAutoReportImpl alloc] init];
    }
    return _impl;
}
@end
