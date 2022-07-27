//
//  ViewController.m
//  DBXKit
//
//  Created by 调包侠 on 2021/7/4.
//

#import "ViewController.h"
#import "NSDictionary+dbx_valuePath.h"
#import "NSObject+dbx_modelValue.h"
#import "MnaLabelsView.h"
#import <QMUIKit/QMUIKit.h>
#import "DBXAutoReport.h"
#import "TextAutoReportImpl.h"

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
    self.labelsView.frame = CGRectMake(20, 50, 200, 20);
    self.labelsView.labelsArray = @[@"texticonbig",@"texticon",@"texticon1"];
    self.labelsView.accessoryPadding = ^UIImage * _Nonnull(NSInteger index) {
        return [UIImage imageNamed:@"tag_master"];
    };
    self.labelsView.imageSetter = ^(UIImageView * _Nonnull imageView, NSString * _Nonnull imgContent) {
        imageView.image = [UIImage imageNamed:imgContent];
    };
    
    [[DBXAutoReportManager sharedInstance] enableAutoReport];
    [[DBXAutoReportManager sharedInstance] setReportConfig:@{
        @"ViewController_clickedButton:" : @{@"title" : @"234",@"icon" : @"abc.jpg"}
//        @"ViewController/UIView/UIView[01]/UIButton[1]" : @{@"title" : @"234",@"icon" : @"abc.jpg"}
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
}
- (IBAction)clickedButton2:(id)sender {
}

- (void)clickedButton:(UIButton *)sender
{
    
}

- (void)clickedButtonInCell:(UIButton *)sender
{
    
}

- (void)clickedImageView:(UITapGestureRecognizer *)tapGes {
    
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
