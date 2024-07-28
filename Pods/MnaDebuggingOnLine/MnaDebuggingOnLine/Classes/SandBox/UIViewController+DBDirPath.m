//
//  UIViewController+DBDirPath.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2022/8/17.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "UIViewController+DBDirPath.h"
#import "MnaSandBoxItemCollectionViewCell.h"
#import "MnaDBTextViewController.h"
#import "MnaDBFileBrowseViewController.h"
#import "MnaDBSandBoxFileListViewController.h"
#define DBPATH_FILE_TXT_TYPES @[@"", @"txt", @"plist", @"json", @"xml", @"strings", @"log", @"setting", @"js", @"config"]

// 文件VC
@implementation UIViewController (DBDirPath)

- (void)addLastButton {
    UIBarButtonItem *lastItem = [[UIBarButtonItem alloc] initWithTitle:@"上一层" style:UIBarButtonItemStyleDone target:self action:@selector(lastAction)];
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
    [newItems addObject:lastItem];
    self.navigationItem.leftBarButtonItems = newItems;
}

- (void)lastAction {
    NSString *path = nil;
    if ([self respondsToSelector:@selector(path)]) {
        path = [self performSelector:@selector(path)];
    }
    if (!path) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    path = [path stringByDeletingLastPathComponent];
    NSMutableArray *newVCs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if (newVCs.count <= 1) {
        return;
    }
    
    // 导航栏里的上一层
    UIViewController *navigationLastVC = newVCs[newVCs.count - 2];
    NSString *lastPath = nil;
    if ([navigationLastVC respondsToSelector:@selector(path)]) {
        lastPath = [navigationLastVC performSelector:@selector(path)];
    }
    if (![lastPath isEqualToString:path]) {
        // 路径path的上一级目录
        UIViewController *lastVC = [self getVCOfPaths:path];
        [newVCs insertObject:lastVC atIndex:newVCs.count -1];
        self.navigationController.viewControllers = newVCs.copy;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoPath:(NSString *)fullPath {
    UIViewController *vc = [self getVCOfPaths:fullPath];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIViewController *)getVCOfPaths:(NSString *)fullPath {
    if (!fullPath) {
        return nil;
    }
    UIViewController *controller = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
    if ([fileAttributes.fileType isEqualToString:NSFileTypeDirectory]) {
        controller = [[MnaDBSandBoxFileListViewController alloc] init];
        ((MnaDBSandBoxFileListViewController *)controller).path = fullPath;
    } else if ([DBPATH_FILE_TXT_TYPES containsObject:fullPath.pathExtension]) {
        controller = [[MnaDBTextViewController alloc] init];
        ((MnaDBTextViewController *)controller).path = fullPath;
    } else {
        controller = [[MnaDBFileBrowseViewController alloc] init];
        ((MnaDBFileBrowseViewController *)controller).path = fullPath;
    }
    return controller;
}

@end
