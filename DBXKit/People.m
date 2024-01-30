//
//  People.m
//  DBXKit
//
//  Created by asherluo on 2022/9/14.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "People.h"

@interface People ()

@property(nonatomic, strong) NSString *name;

@end

@implementation People

- (void)run {
    BOOL condition = NO;
    dispatch_queue_t customQueue;
    
    /*
    BOOL isGroup = ...;
    
    if (isGroup) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            queryGroupInfo();
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                queryGroupMemberInfo();
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    reloadGroupUI();
                    reloadInfoUI();
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        queryHistory();
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            reloadHistoryUI();
                        });
                    });
                });
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            queryUserInfo();
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                queryFriendRelation();
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    reloadFriendUI();
                    reloadInfoUI();
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        queryHistory();
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            reloadHistoryUI();
                        });
                    });
                });
            });
        });
    }*/
}


- (void)test:(NSString *)test {
    NSLog(@"%@", test);
}

- (instancetype)initWithNum:(NSNumber *)num
{
    self = [super init];
    if (self) {
        self.idnum = [num integerValue];
    }
    return self;
}

- (instancetype)initWithNum:(NSNumber *)num name:(NSString *)name size:(float)size
{
    self = [super init];
    if (self) {
        self.idnum = [num integerValue];
    }
    return self;
}

- (void)dealloc {
    
}

@end
