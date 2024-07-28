//
//  MnaDebugging.m
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/11/6.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDebugging.h"
#import "MnaDBHomePageViewController.h"
#import "UIView+DB.h"
#import "MnaDBHelper.h"

@interface MnaDebugging ()

@property(nonatomic, strong) UIWindow *mainWindow;
// 根vc
@property(nonatomic, strong) MnaDBHomePageViewController *rootVC;
// 初始化的起始位置
@property(nonatomic, assign) CGPoint beginPoint;

@end
// 对外接口
@implementation MnaDebugging

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MnaDebugging *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initWindow];
    }
    return self;
}

+ (void)beginAtPoint:(CGPoint)point {
    MnaDebugging.sharedInstance.beginPoint = point;
}

+ (void)show {
    MnaDebugging.sharedInstance.mainWindow.hidden = NO;
}

+ (void)hide {
    MnaDebugging.sharedInstance.mainWindow.hidden = YES;
}

- (void)initWindow {
    if (!self.mainWindow) {
        self.mainWindow = [[UIWindow alloc] init];
        self.mainWindow.backgroundColor = nil;
        self.mainWindow.windowLevel = UIWindowLevelAlert;
        
        self.rootVC = [[MnaDBHomePageViewController alloc] init];
        self.mainWindow.rootViewController = self.rootVC;
        __weak __typeof(self)weakSelf = self;
        self.mainWindow.db_hitTestBlock = ^__kindof UIView * _Nonnull(CGPoint point, UIEvent * _Nonnull event, __kindof UIView * _Nonnull originalView) {
            UIView *view = (originalView == weakSelf.mainWindow || originalView == weakSelf.rootVC.view.superview) || originalView.superview == weakSelf.mainWindow ? nil : originalView;
            return view;
        };
    }
}

- (void)setBeginPoint:(CGPoint)beginPoint {
    _beginPoint = beginPoint;
    self.rootVC.controlPoint = beginPoint;
}

@end
