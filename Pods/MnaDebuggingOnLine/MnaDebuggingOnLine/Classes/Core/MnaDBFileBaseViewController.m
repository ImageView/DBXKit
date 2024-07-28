//
//  MnaDBFileBaseViewController.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2022/8/17.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBFileBaseViewController.h"
#import "MnaDBHelper.h"
#import "UIViewController+DBDirPath.h"

@interface MnaDBFileBaseViewController ()

@end
// 显示文件路径的基类
@implementation MnaDBFileBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStyleDone target:self action:@selector(shareAction)];
    if (self.path) {
        UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithTitle:@"复制路径" style:UIBarButtonItemStyleDone target:self action:@selector(copyPath)];
        self.navigationItem.rightBarButtonItems = @[shareItem, copyItem];
    } else {
        self.navigationItem.rightBarButtonItems = @[shareItem];
    }
    [self addLastButton];
}

- (void)copyPath {
    [MnaDBHelper showMessage:@"已拷贝到剪切板" inVC:self];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.path;
}

- (void)shareAction {
    if (self.path) {
        NSURL *url = [NSURL fileURLWithPath:self.path isDirectory:NO];
        if (url) {
            [MnaDBHelper showShareActivityWithItems:@[url]];
        }
    }
}

@end
