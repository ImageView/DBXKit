//
//  DBXListSectionControllerExtension.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/7/27.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListSectionControllerExtension_h
#define DBXListSectionControllerExtension_h

#import "DBXListSectionController.h"

@interface DBXListSectionController ()

// 所在控制器
@property (nonatomic, weak, readwrite) UIViewController *viewController;
// 当前section
@property (nonatomic, assign, readwrite) NSInteger section;

@end

#endif /* DBXListSectionControllerExtension_h */
