//
//  ViewController.m
//  DBXKit
//
//  Created by DBX on 2021/7/4.
//

#import "ViewController.h"
#import "DBXExtension.h"
#import "MnaLabelsView.h"
#import "DBXAutoReport.h"
#import "TextAutoReportImpl.h"
#import "MnaTaskTimerManager.h"
#import "DBXTextModel.h"
#import "NSObject+PropertyObserver.h"

@interface ViewController ()<MnaLabelsViewDelegate, MnaLabelsViewUIDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

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
    self.labelsView.frame = CGRectMake(20, 50, 200, 90);
    self.labelsView.labelsArray = @[@"texticonbig",@"texticon",@"texticon1"];

    
    /// 测试带图标的文字
//    self.labelsView.itemInsets = UIEdgeInsetsMake(0, 20, 0, 90);
//    self.labelsView.accessorySpace = 20;
//    self.labelsView.accessoryPadding = ^UIImage * _Nonnull(NSInteger index) {
//        return [UIImage imageNamed:@"tag_master"];
//    };
    
    /// 测试纯图片
//    self.labelsView.itemSize = CGSizeMake(50, 30);
//    self.labelsView.imageSetter = ^(UIImageView * _Nonnull imageView, NSString * _Nonnull imgContent) {
//        imageView.image = [UIImage imageNamed:imgContent];
//    };
//    self.labelsView.itemInsets = UIEdgeInsetsMake(10, 20, 0, 2);
    
    /// 测试富文本
//    NSMutableArray *arr = [NSMutableArray array];
//    for (int i = 0; i<3; i++) {
//        NSAttributedString *att = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"哈哈%d\n123",i] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:30], NSForegroundColorAttributeName : [UIColor redColor]}];
//        [arr addObject:att];
//    }
    self.labelsView.itemInsets = UIEdgeInsetsMake(0, 5, 0, 5);
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
