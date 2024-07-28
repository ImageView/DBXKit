//
//  UIViewController+DBDirPath.h
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2022/8/17.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 文件VC
@interface UIViewController (DBDirPath)

// 增加返回上一级功能
- (void)addLastButton;
// 跳转到某个目录下
- (void)gotoPath:(NSString *)fullPath;
@end

NS_ASSUME_NONNULL_END
