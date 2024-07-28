//
//  MnaDBTextViewController.h
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2021/12/16.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBFileBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

// 显示文本内容页面
@interface MnaDBTextViewController : MnaDBFileBaseViewController
// 内容
@property (nonatomic, copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
