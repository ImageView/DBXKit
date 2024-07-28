//
//  MnaDBNetworkListenViewController.m
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/12/12.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBNetworkListenViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIView+DB.h"
#import "MnaDBTextViewController.h"
#import "UIViewController+DB.h"

@interface MnaDBNetworkListenViewController ()<UITableViewDataSource, UITableViewDelegate>
// 列表
@property(nonatomic, strong) UITableView *tableView;
// 容器视图，所有UI都放在这上面
@property(nonatomic, strong) UIView *containView;
// 关闭按钮
@property(nonatomic, strong) UIButton *dismissButton;
// 数据源
@property(nonatomic, strong) NSMutableArray *dataSource;

@end
// 网络诊断页面
@implementation MnaDBNetworkListenViewController

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MnaDBNetworkListenViewController *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"沙盒列表";
    self.view.backgroundColor = [UIColor clearColor];
    
    __weak __typeof(self)weakSelf = self;
    self.view.db_hitTestBlock = ^__kindof UIView * _Nonnull(CGPoint point, UIEvent * _Nonnull event, __kindof UIView * _Nonnull originalView) {
        if (![originalView isDescendantOfView:self.containView]) {
            
            return nil;// 也即不再传递这次事件了，相当于无效点击
        }
        return originalView;
    };
    
    _dataSource = [NSMutableArray array];
    [self setupSubviews];
}

- (void)setupSubviews {
    [self.view addSubview:self.containView];
    [self.containView addSubview:self.dismissButton];
    [self.containView addSubview:self.tableView];
    self.containView.frame = CGRectMake(30, 300, 300, 300);
    self.dismissButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.containView.frame), 40);
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.dismissButton.frame), CGRectGetWidth(self.containView.frame), CGRectGetHeight(self.containView.frame) - 40);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startListenJson];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopListenJson];
}

+ (nullable id)db_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    id result = [MnaDBNetworkListenViewController db_JSONObjectWithData:data options:opt error:error];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MnaDBNetworkListenViewController sharedInstance].dataSource addObject:[result description]];
        [[MnaDBNetworkListenViewController sharedInstance].tableView reloadData];
        [[MnaDBNetworkListenViewController sharedInstance].tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[MnaDBNetworkListenViewController sharedInstance].dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
    
    return result;
}

- (void)startListenJson {
    SEL methodSel = @selector(JSONObjectWithData:options:error:);
    Method method = class_getClassMethod(NSJSONSerialization.class, methodSel);
    
    SEL dbSelector = @selector(db_JSONObjectWithData:options:error:);
    Method newMethod = class_getClassMethod(MnaDBNetworkListenViewController.class, dbSelector);
    method_exchangeImplementations(method, newMethod);
}

// 停止监听暂时直接处理为交换回来
- (void)stopListenJson {
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    [self startListenJson];
}

- (void)panGesControlButton:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    [gesture setTranslation:CGPointZero inView:gesture.view];
    UIView *view = gesture.view;
    view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
}

- (void)dismissAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <Tableview datasource && delegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MnaDBNetworkListenViewController" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MnaDBTextViewController *controller = [[MnaDBTextViewController alloc] init];
    controller.content = self.dataSource[indexPath.row];
    [controller showFromVC:self];
//    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Getter
- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] init];
        _containView.backgroundColor = [UIColor whiteColor];
        _containView.layer.shadowColor = [UIColor blackColor].CGColor;
        _containView.layer.shadowOffset = CGSizeMake(5,5);
        _containView.layer.shadowOpacity = 0.8;//阴影透明度
        _containView.layer.shadowRadius = 4;
        _containView.layer.cornerRadius = 5;
        
        [_containView allowFollow];
//        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesControlButton:)];
//        [_containView addGestureRecognizer:panGes];
    }
    return _containView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(30, 300, 300, 300) style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColor.blackColor;
//        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"MnaDBNetworkListenViewController"];
        _tableView.rowHeight = 100;
        
//        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesControlButton:)];
//        [_tableView addGestureRecognizer:panGes];
    }
    return _tableView;
}

- (UIButton *)dismissButton
{
    if (!_dismissButton) {
        _dismissButton = [[UIButton alloc] init];
        [_dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_dismissButton setTitle:@"监听中，点我停止监听" forState:UIControlStateNormal];
        [_dismissButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

@end
