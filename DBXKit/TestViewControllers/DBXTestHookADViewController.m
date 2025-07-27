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
    self.dataSource = [NSMutableArray arrayWithObjects:@"a", @"b", @"c", @"d", @(1), @"e", @"f", @(2),@"g", @(3), @"h", @"i", @"j", @"k", @"l", nil];
    self.adapter = [[DBXListAdapter alloc] initWithViewController:self];
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}

- (NSArray *)objectsForListAdapter:(DBXListAdapter *)adapter {
    return self.dataSource;
}

- (DBXListSectionController *)listAdapter:(DBXListAdapter *)adapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]]) {
        return [[DBXTestHookADNumberSectionController alloc] init];
    }
    return [[DBXTestHookADSectionController alloc] init];
}



//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.dataSource.count;
//}
//
//- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    return cell;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(300, 50);
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"abc");
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(100, 50);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
//        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
