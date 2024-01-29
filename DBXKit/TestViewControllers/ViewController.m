//
//  ViewController.m
//  DBXKit
//
//  Created by DBX on 2021/7/4.
//

#import "ViewController.h"
#import "DBXExtension.h"
#import "DBXAutoReport.h"
#import "TextAutoReportImpl.h"
#import "MnaTaskTimerManager.h"
#import "DBXTextModel.h"
#import "NSObject+PropertyObserver.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *butView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property(nonatomic, strong) TextAutoReportImpl *impl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[DBXAutoReportManager sharedInstance] enableAutoReport];
//    [[DBXAutoReportManager sharedInstance] setReportConfig:@{
//        @"ViewController_clickedButton:" : @{@"title" : @"234",@"icon" : @"abc.jpg"},
////        @"ViewController/UIView/UIView[01]/UIButton[1]" : @{@"title" : @"234",@"icon" : @"abc.jpg"}
//        @"ViewController_clickedImageView:" : @{@"title": @"点击了绿色图片"},
//        @"ViewController_clickedButtonInCell:":@{@"111" : @"123"}
//    }];
//    [DBXAutoReportManager sharedInstance].impl = self.impl;
    
    self.button1.dbx_reportID = @"2341";
    
    [self.button1 addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.butView addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2.superview bringSubviewToFront:self.button2];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"abc"];
    
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedImageView:)]];
    
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"你好%@科二里%@得瑟我%@看了%@屌丝", @"a".beginDelimiter, @"a".endDelimiter, @"b".beginDelimiter, @"b".endDelimiter]];
    attStr = [attStr dbx_addAttributes:@{NSForegroundColorAttributeName:UIColor.redColor} delimiter:@"a"];
    attStr = [attStr dbx_addAttributes:@{NSForegroundColorAttributeName:UIColor.blueColor} delimiter:@"b"];

    self.textLabel.attributedText = attStr;
//    [self testTaskManager];
    [self testObserver];
}

- (void)testTaskManager {
    [[MnaTaskTimerManager sharedInstance] addCycleTask:^{
        NSLog(@"testTaskManager");
    } timeInterval:3 runCount:10 threadMode:MnaThreadModeMain];
}

- (void)testChain {
    
}

- (IBAction)clickedButton2:(id)sender {
    
}

- (void)clickedButton:(UIButton *)sender
{
    
}

- (void)clickedButtonInCell:(UIButton *)sender
{
    NSLog(@"%s", __func__);
}

- (void)clickedImageView:(UITapGestureRecognizer *)tapGes {
    NSLog(@"%s", __func__);
}

- (void)testObserver {
    DBXTextModel *model = [[DBXTextModel alloc] init];
    [model dbx_addObserverForKeyPath:@"name" valueChange:^(id _Nonnull value) {
        NSLog(@"%s name=%@",__func__, value);
    }];
    [model dbx_addObserverForKeyPath:@"age" valueChange:^(id _Nonnull value) {
        NSLog(@"%s age=%@",__func__, value);
    }];
    
    model.name = @"asherluo";
    model.age = 18;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        model.name = @"asherluo1";
        model.age = 19;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [model dbx_removeObserverForKeyPath:@"age"];
        model.name = @"asherluo2";
        model.age = 20;
    });
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


- (TextAutoReportImpl *)impl {
    if (!_impl) {
        _impl = [[TextAutoReportImpl alloc] init];
    }
    return _impl;
}
@end
