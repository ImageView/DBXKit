//
//  DBXGestureTarget.h
//  DBXKit
//
//  Created by asherluo on 2022/7/31.
//  Copyright © 2022 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXGestureTarget : NSObject

// 上报id，用于点击时传递给view层
@property(nonatomic, strong) NSString *reportID;;

//  初始化方法
+ (instancetype)gesTureTargetWithGesture:(UIGestureRecognizer *)gesture;

- (void)dbx_gestureAutoReport:(UIGestureRecognizer *)gesture;
@end

NS_ASSUME_NONNULL_END
