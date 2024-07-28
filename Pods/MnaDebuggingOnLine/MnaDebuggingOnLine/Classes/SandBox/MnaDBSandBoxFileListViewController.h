//
//  MnaDBSandBoxFileListViewController.h
//  AFNetworking
//
//  Created by 罗俊宇 on 2021/12/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 沙盒工具
@interface MnaDBSandBoxFileListViewController : UIViewController

// 是否是根目录
@property(nonatomic, assign) BOOL isRoot;
// 当前路径
@property (nonatomic, copy) NSString *path;

@end

NS_ASSUME_NONNULL_END
