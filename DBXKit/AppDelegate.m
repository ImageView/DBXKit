//
//  AppDelegate.m
//  DBXKit
//
//  Created by DBX on 2021/7/4.
//

#import "AppDelegate.h"
//#import "ViewController.h"
#import "DBXChainViewController.h"
#import "DBXConfig.h"
#import <QMUIKit/QMUIKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [DBXConfig sharedInstance].debug = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testConfig" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *vclist = dict[@"testvc"];
    NSMutableArray *vcInstance = [NSMutableArray array];
    
    for (NSDictionary *vcDic in vclist) {
        NSString *vcClassName = vcDic[@"class"];
        Class cls = NSClassFromString(vcClassName);
        NSString *sb = vcDic[@"storyboard"];
        NSString *xib = vcDic[@"xib"];
        UIViewController *vc;
        if (sb) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:sb bundle:nil];
            vc = [storyboard instantiateViewControllerWithIdentifier:@"vc1"];
        } else if (xib) {
            vc = [[cls alloc] initWithNibName:xib bundle:nil];
        } else {
            vc = [[cls alloc] init];
        }
        vc.title = vcDic[@"title"];
        [vcInstance addObject:[[UINavigationController alloc] initWithRootViewController:vc]];
    }
    UITabBarController *tabCon = [[UITabBarController alloc] init];
    
    [tabCon setViewControllers:vcInstance.copy];
    _window.rootViewController = tabCon;
    [_window makeKeyAndVisible];
    QMUICMI.shouldPrintDefaultLog = NO;
    QMUICMI.shouldPrintInfoLog = NO;
    QMUICMI.shouldPrintWarnLog = NO;
    QMUICMI.sendAnalyticsToQMUITeam = NO;
    return YES;
}


@end
