//
//  DBXStubURLProtocol.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubURLProtocol.h"
#import "DBXStub.h"
#import "DBXStubsResponse.h"

@interface DBXStubURLProtocol ()
@property(nonatomic, strong) DBXStubRule *stubRule;     // 本次生效的规则
@property(nonatomic, assign) CFRunLoopRef clientRunLoop;    // 请求所在的runloop
@property(nonatomic, assign, getter=isStop) BOOL stop;
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
    self.clientRunLoop = CFRunLoopGetCurrent();
    NSURLRequest *request = self.request;
    id<NSURLProtocolClient> client = self.client;
    if (!self.stubRule) {
        NSError *error = [NSError errorWithDomain:@"DBXStubError" code:-1 userInfo:@{
            NSLocalizedFailureReasonErrorKey : @"Stub has been removed BEFORE the response had time to be sent.",
            NSURLErrorFailingURLErrorKey : request.URL
        }];
        [client URLProtocol:self didFailWithError:error];
        return;
    }
    DBXStubsResponse *response = self.stubRule.responseBlock(request);
    if (response.error) {
        [self executeOnClientRunLoopAfterDelay:response.requestTime block:^{
            if (!self.isStop) {
                [client URLProtocol:self didFailWithError:response.error];
            }
        }];
        return;
    }
    NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:response.statusCode HTTPVersion:@"HTTP/1.1" headerFields:response.httpHeaders];
    if (request.HTTPShouldHandleCookies && request.URL) {
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.httpHeaders forURL:request.URL];
        if (cookies) {
            [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookies:cookies forURL:request.URL mainDocumentURL:request.mainDocumentURL];
        }
    }
    [self executeOnClientRunLoopAfterDelay:response.requestTime block:^{
        // 开始发头信息
        [client URLProtocol:self didReceiveResponse:urlResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        if (response.inputStream.streamStatus == NSStreamStatusNotOpen) {
            [response.inputStream open];
        }
        
    }];
}

- (void)stopLoading {
    
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)executeOnClientRunLoopAfterDelay:(NSTimeInterval)delayInSeconds block:(dispatch_block_t)block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFRunLoopPerformBlock(self.clientRunLoop, kCFRunLoopDefaultMode, block);
        CFRunLoopWakeUp(self.clientRunLoop);
    });
}

@end
