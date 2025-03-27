//
//  DBXStubURLProtocol.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubURLProtocol.h"
#import "DBXStub.h"

@interface DBXStubURLProtocol ()
@property(nonatomic, strong) DBXStubRule *stubRule;     // 本次生效的规则
@end

@implementation DBXStubURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    DBXStubRule *stubRule = [DBXStub findMatchStubForRequest:request];
    if (stubRule) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    DBXStubURLProtocol *proto = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    proto.stubRule = [DBXStub findMatchStubForRequest:request];
    return proto;
}

- (void)startLoading {
    
}

- (void)stopLoading {
    
}

- (NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
