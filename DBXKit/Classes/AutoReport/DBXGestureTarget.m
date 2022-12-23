//
//  DBXGestureTarget.m
//  DBXKit
//
//  Created by asherluo on 2022/7/31.
//  Copyright © 2022 DBX. All rights reserved.
//

#import "DBXGestureTarget.h"
#import "DBXAutoReportManager.h"
#import "UIView+DBXAR.h"
// 手势model
@implementation DBXGestureTarget

+ (instancetype)gesTureTargetWithGesture:(UIGestureRecognizer *)gesture
{
    NSString *gestureType = NSStringFromClass(gesture.class);
    if ([gesture isMemberOfClass:UITapGestureRecognizer.class] ||
        [gesture isMemberOfClass:UILongPressGestureRecognizer.class] ||
        [gestureType isEqualToString:@"_UIContextMenuSelectionGestureRecognizer"]) {
        return [[DBXGestureTarget alloc] init];
    }
    return nil;
}

- (void)dbx_gestureAutoReport:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded &&
        gesture.state != UIGestureRecognizerStateCancelled) {
        return;
    }
    UIView *clickedView = gesture.view;
    clickedView.dbx_reportID = self.reportID;
    [[DBXAutoReportManager sharedInstance] report:clickedView];
}



@end
