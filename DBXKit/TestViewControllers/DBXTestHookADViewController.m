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
    
    UIBarButtonItem *leftItem =
        [[UIBarButtonItem alloc] initWithTitle:@"全量刷新" style:UIBarButtonItemStylePlain target:self action:@selector(sectionColtrollerReload)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem =
        [[UIBarButtonItem alloc] initWithTitle:@"局部刷新" style:UIBarButtonItemStylePlain target:self action:@selector(sectionColtrollerUpdate)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    DBXListArrayWrapper *wrapper = [[DBXListArrayWrapper alloc] initWithItems:@[@"插入一条",@"删除最后一条",@"修改最后一条",@"移动"] uniqueIdentifier:@"make"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.dataSource = [NSMutableArray arrayWithObjects:wrapper, @"广告1",@"啥也没有1",@"广告3",@"啥也没有2",@"啥也没有3",@"啥也没有4", nil];
//        [self.adapter performUpdatesAnimated:YES completion:nil];
        [self.adapter reloadData];
    });
}

- (void)sectionColtrollerReload {
    [self.adapter reloadData];
}

- (void)sectionColtrollerUpdate {
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finish) {
        NSLog(@"刷新完成performUpdatesAnimated");
    }];
}

- (void)deleteObjectItem:(NSInteger)item {
    if (item < 0) {
        item = self.dataSource.count-1;
    }
    [self.dataSource removeObjectAtIndex:item];
}
- (void)insertObjectToItem:(NSInteger)item {
    if (item < 0) {
        item = self.dataSource.count;
    }
    [self.dataSource insertObject:[NSString stringWithFormat:@"新插入的数据%f", [[NSDate date] timeIntervalSince1970]] atIndex:item];
}
- (void)updateObject:(NSString *)obj atItem:(NSInteger)item {
    if (item < 0) {
        item = self.dataSource.count-1;
    }
    [self.dataSource replaceObjectAtIndex:item withObject:[NSString stringWithFormat:@"替换的数据%f", [[NSDate date] timeIntervalSince1970]]];
}
- (void)moveObject {
    id obj = self.dataSource.lastObject;
    [self.dataSource removeLastObject];
    [self.dataSource insertObject:obj atIndex:self.dataSource.count - 1];
}

#pragma mark - DBXListAdapterDataSource
- (NSArray *)objectsForListAdapter:(DBXListAdapter *)adapter {
    return self.dataSource;
}

- (DBXListSectionController *)listAdapter:(DBXListAdapter *)adapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        if ([object hasPrefix:@"广告"]) {
            return [[DBXTestADSectionController alloc] init];
        }
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
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 1;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    }
    return _collectionView;
}

@end
