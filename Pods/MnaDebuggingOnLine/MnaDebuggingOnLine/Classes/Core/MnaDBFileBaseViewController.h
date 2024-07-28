//
//  MnaDBFileBaseViewController.h
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2022/8/17.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 显示文件路径的基类
@interface MnaDBFileBaseViewController : UIViewController

// 文件路径
@property (nonatomic, copy) NSString *path;

@end

NS_ASSUME_NONNULL_END
