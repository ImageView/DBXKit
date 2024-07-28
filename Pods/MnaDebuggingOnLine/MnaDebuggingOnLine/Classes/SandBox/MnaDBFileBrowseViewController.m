//
//  MnaDBFileBrowseViewController.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2022/8/16.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBFileBrowseViewController.h"
#import "MnaDBHelper.h"
#import "UIViewController+DBDirPath.h"

@interface MnaDBFileBrowseViewController ()

// 图片视图
@property(nonatomic, strong) UIImageView *iconImgView;

@end

// 文件预览
@implementation MnaDBFileBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.iconImgView];
    [self.iconImgView sizeToFit];
    self.iconImgView.center = self.view.center;
    
    if (self.path) {
        self.title = self.path.lastPathComponent;
    }
}

#pragma mark - Getter
- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeCenter;
        _iconImgView.image = [MnaDBHelper imageWithName:@"icons_file_what"];
    }
    return _iconImgView;
}

@end
