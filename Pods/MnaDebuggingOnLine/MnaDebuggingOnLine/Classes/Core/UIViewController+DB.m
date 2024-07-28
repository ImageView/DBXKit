//
//  UIViewController+DB.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2021/12/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "UIViewController+DB.h"

@implementation UIViewController (DB)
// VC分类
- (void)showFromVC:(UIViewController *)vc {
    if (vc.navigationController) {
        [vc.navigationController pushViewController:self animated:YES];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
        nav.navigationBar.tintColor = [UIColor whiteColor];
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *appperance = [[UINavigationBarAppearance alloc] init];
            //添加背景色
            appperance.backgroundColor = [UIColor colorWithRed:219.0/255 green:112.0/255 blue:147/255.0 alpha:1];
            appperance.shadowImage = [[UIImage alloc]init];
            appperance.shadowColor = nil;
            [appperance setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor}];
            nav.navigationBar.standardAppearance = appperance;
            nav.navigationBar.scrollEdgeAppearance = appperance;
            nav.navigationBar.compactAppearance = appperance;
            nav.navigationBar.compactScrollEdgeAppearance = appperance;
        }
        [vc presentViewController:nav animated:YES completion:nil];
    }
}

@end
