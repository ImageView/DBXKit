//
//  MnaDBSandBoxFileListViewController.m
//  AFNetworking
//
//  Created by 罗俊宇 on 2021/12/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBSandBoxFileListViewController.h"
#import "MnaSandBoxItemCollectionViewCell.h"
#import "MnaDBHelper.h"
#import "MnaDBTextViewController.h"
#import "MnaDBFileBrowseViewController.h"
#import "UIViewController+DBDirPath.h"

@interface MnaDBSandBoxFileListViewController ()<UICollectionViewDataSource, MnaSandBoxItemCollectionViewCellDelegate>
// 沙盒主视图
@property(nonatomic, strong) UICollectionView *collectionView;
// 数据源头
@property(nonatomic, strong) NSMutableArray *dataSource;

@end
// 沙盒工具
@implementation MnaDBSandBoxFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    if (!self.path) {
        self.path = NSHomeDirectory();
        self.isRoot = YES;
    } else {
        [self addLastButton];
    }
    
    if (!self.title) {
        self.title = self.path.lastPathComponent;
    }
    
    [self loadData];
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(rightItemAction:)];
    if (self.isRoot) {
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithTitle:@"前往"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(search)];
        self.navigationItem.rightBarButtonItems = @[reloadItem, searchItem];
    } else {
        self.navigationItem.rightBarButtonItems = @[reloadItem];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

- (void)rightItemAction:(UIButton *)sender {
    [self loadData];
    [self.collectionView reloadData];
}

- (void)search {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入沙盒路径"
                                                                   message:[NSString stringWithFormat:@"输入的路径若以【/var/】开头将忽略当前路径，当前路径：%@", self.path]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.text = self.path;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alert.textFields.firstObject;
        if (![textField isKindOfClass:[UITextField class]]) {
            return;
        }
        
        NSString *fullPath = nil;
        if ([textField.text hasPrefix:@"/var/"]) {
            fullPath = textField.text;
        } else {
            fullPath = [self.path stringByAppendingPathComponent:textField.text];
        }
        if ([fullPath isEqualToString:self.path]) {
            return;
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            [MnaDBHelper showMessage:@"路径不存在，请检查后重试" inVC:self];
            return;
        }
        [self gotoPath:fullPath];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)loadData {
    self.dataSource = [[[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:nil]
                        sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1,
                                                                       NSString *  _Nonnull obj2) {
        return [obj1.lowercaseString compare:obj2.lowercaseString];
    }] mutableCopy];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MnaSandBoxItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MnaSandBoxItemCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    NSString *subpath = self.dataSource[indexPath.row];
    cell.titleLabel.text = subpath;
    
    NSString *fullPath = [self.path stringByAppendingPathComponent:subpath];
    cell.filePath = fullPath;
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *subpath = self.dataSource[indexPath.row];
    if ([subpath isEqualToString:@"前往"]) {
        [self search];
        return;
    }
    NSString *fullPath = [self.path stringByAppendingPathComponent:subpath];
    [self gotoPath:fullPath];
}

#pragma mark - <MnaSandBoxItemCollectionViewCellDelegate>
- (void)sandBoxItemCollectionViewCellLongPress:(MnaSandBoxItemCollectionViewCell *)cell {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSString *subpath = self.dataSource[indexPath.row];
    if (subpath) {
        NSString *fullPath = [self.path stringByAppendingPathComponent:subpath];
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"你要删除“%@”吗？", subpath]
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleDefault handler:nil]];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"别手滑" style:UIAlertActionStyleDestructive handler:nil]];

        [alertControl addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
            [self rightItemAction:nil];
        }]];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(70, 110+12);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[MnaSandBoxItemCollectionViewCell class] forCellWithReuseIdentifier:@"MnaSandBoxItemCollectionViewCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

//+ (UIImage *)getThumbnailImageWithPath:(NSString *)path
//{
//    CGImageSourceRef imageSource;
//    imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL);
//    if (imageSource == nil) {
//        return nil;
//    }
//
//    // 图片宽高
//    int imageSize = 100*2;
//    // 缩略图尺寸
//    CFNumberRef thumbSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
//    CFTypeRef imageValues[3];
//    CFStringRef imageKeys[3];
//
//    imageKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
//    imageValues[0] = (CFTypeRef)kCFBooleanTrue;
//
//    imageKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
//    imageValues[1] = (CFTypeRef)kCFBooleanTrue;
//
//    //缩放键值对
//
//    imageKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
//    imageValues[2] = (CFTypeRef)thumbSize;
//
//    CFDictionaryRef imageOption = CFDictionaryCreate(NULL, (const void **) imageKeys,
//
//                                      (const void **) imageValues, 3,
//
//                                      &kCFTypeDictionaryKeyCallBacks,
//
//                                      &kCFTypeDictionaryValueCallBacks);
//    //获取缩略图
//
//    CGImageRef thumbImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, imageOption);
//
//    CFRelease(imageOption);
//    CFRelease(imageSource);
//    CFRelease(thumbSize);
//
//    UIImage* thumbnailImage = [UIImage imageWithCGImage:thumbImage];
//    //显示缩略图
//    return thumbnailImage;
//
//}

@end
