//
//  DBXLabelsTestViewController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2023/12/31.
//  Copyright © 2023 DBX. All rights reserved.
//

#import "DBXLabelsTestViewController.h"
#import "MnaLabelsView.h"
#import "DBXExtension.h"

@interface DBXLabelsTestViewController ()<MnaLabelsViewDelegate, MnaLabelsViewUIDelegate>
@property (nonatomic, strong) MnaLabelsView *labelsView;

@end

@implementation DBXLabelsTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    [super initSubviews];
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
    
    // 测试富文本
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i<3; i++) {
        NSAttributedString *imageAtt = [NSAttributedString qmui_attributedStringWithImage:[UIImage imageNamed:@"texticonbig"]];
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"哈哈%d123",i] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:30], NSForegroundColorAttributeName : [UIColor redColor]}];
        [att appendAttributedString:imageAtt];
        [arr addObject:att];
    }
    self.labelsView.itemInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    self.labelsView.labelsArray = arr;
    
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

@end
