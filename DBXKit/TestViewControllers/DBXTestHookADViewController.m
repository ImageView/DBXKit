//
//  DBXTestHookADViewController.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/4/7.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXTestHookADViewController.h"
#import "DBXList.h"
#import <QMUIKit/QMUIKit.h>
#import "DBXTestHookADSectionController.h"

@interface DBXTestHookADViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, DBXListAdapterDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) DBXListAdapter *adapter;

@end

@implementation DBXTestHookADViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor qmui_randomColor];
    self.collectionView.frame = self.view.bounds;
    [self.view addSubview:self.collectionView];
    self.dataSource = [NSMutableArray arrayWithObjects:@(1), @(2), @(3),@"广告1", @(4),@(5),@"广告2",@(6),@(7),@"广告3",@(8),@"广告4",@(9),@(10),@(11),@(12),@(13),@(14),@(15),@(16), nil];
    self.adapter = [[DBXListAdapter alloc] initWithViewController:self];
    self.adapter.collectionViewDelegate = self;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}

#pragma mark - DBXListAdapterDataSource
- (NSArray *)objectsForListAdapter:(DBXListAdapter *)adapter {
    return self.dataSource;
}

- (DBXListSectionController *)listAdapter:(DBXListAdapter *)adapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return [[DBXTestHookADNumberSectionController alloc] init];
    }
    return [[DBXTestHookADSectionController alloc] init];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"abc");
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(100, 50);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//        _collectionView.delegate = self;
//        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
