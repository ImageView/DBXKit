//
//  UIApplication+DBXAutoReport.m
//  DBXKit
//
//  Created by 罗俊宇 on 2022/7/10.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "UIApplication+DBXAR.h"
#import "DBXAutoReportManager.h"

@implementation UIApplication (DBXAR)

- (BOOL)dbx_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    BOOL ret = [self dbx_sendAction:action to:target from:sender forEvent:event];
    [[DBXAutoReportManager sharedInstance] report:sender];
    return ret;
}

@end
