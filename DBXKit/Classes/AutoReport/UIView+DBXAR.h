//
//  UIView+DBXAR.h
//  DBXKit
//
//  Created by asherluo on 2022/7/16.
//  Copyright © 2022 DBX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 给UIView扩展一个id
@interface UIView (DBXAR)


// 上报的id，dbx_customReportID赋值的话使用dbx_customReportID，否者使用view的路径
@property(nonatomic, copy) NSString *dbx_reportID;


@end

@interface UIBarItem (DBXAR)
// 上报的id，dbx_customReportID赋值的话使用dbx_customReportID，否者使用view的路径
@property(nonatomic, copy) NSString *dbx_reportID;
@end

NS_ASSUME_NONNULL_END
