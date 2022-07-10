//
//  DBXAutoReportManager.h
//  DBXKit
//
//  Created by asherluo on 2022/7/10.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 自动上报管理类
@interface DBXAutoReportManager : NSObject

+ (instancetype)sharedInstance;

- (void)enableAutoReport;

@end

NS_ASSUME_NONNULL_END
