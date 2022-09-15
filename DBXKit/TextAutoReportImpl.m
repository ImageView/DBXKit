//
//  TextAutoReportImpl.m
//  DBXKit
//
//  Created by asherluo on 2022/7/16.
//  Copyright © 2022 DBX. All rights reserved.
//

#import "TextAutoReportImpl.h"


@implementation TextAutoReportImpl

- (void)clickedView:(UIView *)view reportParams:(NSDictionary *)params {
    NSLog(@"上报了view%@，参数是：%@", view, params);
}

@end
