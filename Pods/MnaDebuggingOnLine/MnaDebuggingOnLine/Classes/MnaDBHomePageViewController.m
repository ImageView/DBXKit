//
//  MnaDBHomePageViewController.m
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/11/7.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBHomePageViewController.h"
#import "UIView+DB.h"
#import "MnaDBHelper.h"
#import "MnaDBUILookViewController.h"
#import "UIViewController+DB.h"
#import "MnaDebugging.h"

@interface MnaDBHomePageViewController ()<UITableViewDelegate, UITableViewDataSource>

// 容器视图，所有UI都放在这上面
@property(nonatomic, strong) UIView *containView;
// 工具列表
@property(nonatomic, strong) UITableView *itemsViews;
// 控制按钮
@property(nonatomic, strong) UIButton *controlButton;
// 工具数据源
@property(nonatomic, strong) NSMutableArray *dataSource;

@end
// 主页面
@implementation MnaDBHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self)weakSelf = self;
    self.view.db_hitTestBlock = ^__kindof UIView * _Nonnull(CGPoint point, UIEvent * _Nonnull event, __kindof UIView * _Nonnull originalView) {
        if (![originalView isDescendantOfView:self.containView] && originalView != weakSelf.controlButton) {
            
            return nil;// 也即不再传递这次事件了，相当于无效点击
        }
        return originalView;
        
//        UIView *view = (originalView == weakSelf.containView  || originalView.superview == weakSelf.containView || originalView == weakSelf.controlButton) ? originalView : nil;
//        return view;
    };
    [self setupSubviews];
    _dataSource = @[
        @{
            @"name" : @"UI检查",
            @"class" : @"MnaDBUILookViewController",
            @"NeedNavigation" : @(NO)
        },
        @{
            @"name" : @"网络请求监听",
            @"class" : @"MnaDBNetworkListenViewController",
            @"NeedNavigation" : @(NO)
        },
        @{
            @"name" : @"查看沙盒",
            @"class" : @"MnaDBSandBoxFileListViewController",
        },
        @{
            @"name" : @"查看UserDefault",
            @"class" : @"MnaDBUserDefaultListViewController",
        },
    ];
}

- (void)setupSubviews {
    [self.view addSubview:self.controlButton];
    [self.view addSubview:self.containView];
    [self.containView addSubview:self.itemsViews];
    
    if (CGPointEqualToPoint(self.controlPoint, CGPointZero)) {
        self.controlPoint = CGPointMake(15, 200);
    }
    self.controlButton.frame = CGRectMake(self.controlPoint.x, self.controlPoint.y, 50, 50);
    self.containView.frame = CGRectMake(CGRectGetMinX(self.controlButton.frame), CGRectGetMaxY(self.controlButton.frame) + 3, 200, 300);
    self.itemsViews.frame = self.containView.bounds;
    self.containView.hidden = YES;
}

- (void)clickedControlButton:(UIButton *)controlBtn {
    controlBtn.selected = !controlBtn.isSelected;
    self.containView.hidden = !self.containView.isHidden;
    if (self.containView.isHidden) {
        return;
    }
    CGSize containSize = self.containView.frame.size;

    CGFloat buttonX = CGRectGetMinX(self.controlButton.frame);
    CGFloat containX = buttonX;
    if (buttonX < CGRectGetWidth(self.view.frame) - containSize.width) {
        containX = buttonX;
    } else {
        containX = CGRectGetMaxX(self.controlButton.frame) - containSize.width;
    }
    
    CGFloat buttonY = CGRectGetMaxY(self.controlButton.frame);
    CGFloat containY = buttonY;
    if (buttonY < CGRectGetHeight(self.view.frame) - containSize.height) {
        containY = buttonY + 3;
    } else {
        containY = CGRectGetMinY(self.controlButton.frame) - containSize.height - 3;
    }
    self.containView.frame = CGRectMake(containX, containY, containSize.width, containSize.height);
}

- (void)panGesControlButton:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    [gesture setTranslation:CGPointZero inView:gesture.view];
    self.controlButton.center = CGPointMake(self.controlButton.center.x + translation.x, self.controlButton.center.y + translation.y);
    self.containView.center = CGPointMake(self.containView.center.x + translation.x, self.containView.center.y + translation.y);
}

- (void)longGesControlButton:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [MnaDebugging hide];
    }
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"abc" forIndexPath:indexPath];
    
    NSDictionary *itemDic = self.dataSource[indexPath.row];
    cell.textLabel.text = itemDic[@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self clickedControlButton:self.controlButton];
    
    NSDictionary *itemDic = self.dataSource[indexPath.row];
    NSString *className = itemDic[@"class"];
    if (![className isKindOfClass:[NSString class]]) {
        return;
    }
    Class ItemClass = NSClassFromString(className);
    if (!ItemClass) {
        return;
    }
    UIViewController *itemHomeVC = [[ItemClass alloc] init];
    itemHomeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    BOOL needNavigation = YES;
    NSNumber *needNavigationNum = itemDic[@"NeedNavigation"];
    if ([needNavigationNum respondsToSelector:@selector(boolValue)]) {
        needNavigation = needNavigationNum.boolValue;
    }
    if (needNavigation) {
        [itemHomeVC showFromVC:self];
    } else {
        [self presentViewController:itemHomeVC animated:NO completion:nil];
    }
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
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesControlButton:)];
        [_containView addGestureRecognizer:panGes];
    }
    return _containView;
}

- (UITableView *)itemsViews
{
    if (!_itemsViews) {
        // tableveiw
        _itemsViews = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _itemsViews.backgroundColor = [UIColor clearColor];
        _itemsViews.delegate = self;
        _itemsViews.dataSource = self;
        [_itemsViews registerClass:[UITableViewCell class] forCellReuseIdentifier:@"abc"];
        _itemsViews.tableFooterView = [[UIView alloc] init];
        _itemsViews.layer.cornerRadius = 5;
    }
    return _itemsViews;
}

- (UIButton *)controlButton
{
    if (!_controlButton) {
        _controlButton = [[UIButton alloc] init];
        [_controlButton setImage:[MnaDBHelper imageWithName:@"icon_cover_normal"] forState:UIControlStateNormal];
        [_controlButton setImage:[MnaDBHelper imageWithName:@"icon_cover_select"] forState:UIControlStateSelected];
        [_controlButton setImage:[MnaDBHelper imageWithName:@"icon_cover_select"] forState:UIControlStateHighlighted];
        _controlButton.adjustsImageWhenHighlighted = NO;
        [_controlButton addTarget:self action:@selector(clickedControlButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesControlButton:)];
        [_controlButton addGestureRecognizer:panGes];
        
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesControlButton:)];
        longGes.minimumPressDuration = 2;
        [_controlButton addGestureRecognizer:longGes];
    }
    return _controlButton;
}

@end
