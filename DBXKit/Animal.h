//
//  Animal.h
//  DBXKit
//
//  Created by asherluo on 2023/1/27.
//  Copyright © 2023 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Animal : NSObject
@property(nonatomic, strong) NSString *name;

- (void)run;

- (void)barking;
@end

NS_ASSUME_NONNULL_END
