//
//  DBXStubURLProtocol.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubURLProtocol.h"

@implementation DBXStubURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return YES;
}

- (void)startLoading {
    
}

- (void)stopLoading {
    
}

- (NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
