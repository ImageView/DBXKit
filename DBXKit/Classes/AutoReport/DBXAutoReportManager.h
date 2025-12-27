//
//  DBXAutoReportManager.h
//  DBXKit
//
//  Created by 调包侠 on 2022/7/10.
//  Copyright © 2022 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 上报的代理
@protocol DBXAutoReportImpl <NSObject>

- (void)clickedView:(UIView *_Nonnull)view reportParams:(NSDictionary *_Nonnull)params;

@end

NS_ASSUME_NONNULL_BEGIN

// 自动上报管理类
@interface DBXAutoReportManager : NSObject

// 上报的实现代理
@property(nonatomic, weak) id <DBXAutoReportImpl> impl;

+ (instancetype)sharedInstance;

- (void)enableAutoReport;

// 设置需要上报的id以及对应的参数
- (void)setReportConfig:(NSDictionary *)configDic;

- (void)report:(UIView *)sender;

@end

NS_ASSUME_NONNULL_END
