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
#import "DBXTestHookADCustomFlowLayout.h"

@interface DBXTestHookADViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, DBXListAdapterDataSource, DBXTestHookADSectionControllerDelegate>

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
    self.adapter = [[DBXListAdapter alloc] initWithViewController:self];
    self.adapter.collectionViewDelegate = self;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    
    UIBarButtonItem *rightItem =
        [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(sectionColtrollerReload)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.dataSource = [NSMutableArray arrayWithObjects:@"插入一条",@"删除最后一条",@"广告1",@"修改最后一条",@"广告2",@"啥也没有1",@"广告3",@"啥也没有2",@"啥也没有3",@"啥也没有4",@"啥也没有4", @"啥也没有2", @"啥也没有3", nil];
        [self.adapter reloadData];
    });
}

- (void)sectionColtrollerReload {
    [self.adapter reloadData];
}
- (void)deleteObjectItem:(NSInteger)item {
    if (item < 0) {
        item = self.dataSource.count-1;
    }
    [self.dataSource removeObjectAtIndex:item];
}
- (void)insertObjectToItem:(NSInteger)item {
    if (item < 0) {
        item = self.dataSource.count-1;
    }
    [self.dataSource insertObject:@"新插入的数据" atIndex:item];
}
- (void)updateObject:(NSString *)obj atItem:(NSInteger)item {
    if (item < 0) {
        item = self.dataSource.count-1;
    }
    [self.dataSource replaceObjectAtIndex:item withObject:@"新替换的数据"];
}

#pragma mark - DBXListAdapterDataSource
- (NSArray *)objectsForListAdapter:(DBXListAdapter *)adapter {
    return self.dataSource;
}

- (DBXListSectionController *)listAdapter:(DBXListAdapter *)adapter sectionControllerForObject:(id)object {
    if ([object hasPrefix:@"广告"]) {
        return [[DBXTestADSectionController alloc] init];
    }
    DBXTestHookADSectionController *sectionController =  [[DBXTestHookADSectionController alloc] init];
    sectionController.delegate = self;
    return sectionController;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"abc");
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    }
    return _collectionView;
}

@end
