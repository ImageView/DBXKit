//
//  UIApplication+DBXAR.h
//  DBXKit
//
//  Created by 罗俊宇 on 2022/7/10.
//  Copyright © 2022 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 交互的总接口，UIControl的交互事件都会到这里
@interface UIApplication (DBXAR)

- (BOOL)dbx_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event;
@end

NS_ASSUME_NONNULL_END
