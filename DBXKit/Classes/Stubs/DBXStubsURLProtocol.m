//
//  DBXStubsURLProtocol.m
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/24.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubsURLProtocol.h"
#import "DBXStubs.h"
#import "DBXStubsResponse.h"

static NSTimeInterval const kslotTime = 0.25;

@interface DBXStubsTimingInfo : NSObject
@property(nonatomic, assign) NSTimeInterval slotTime;   // 时隙时间
@property(nonatomic, assign) double slotSize;
@property(nonatomic, assign) double cumulativeChunkSize;
@end

@implementation DBXStubsTimingInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        _slotTime = kslotTime;
    }
    return self;
}
@end

@interface DBXStubsURLProtocol ()
@property(nonatomic, strong) DBXStubsRule *stubRule;     // 本次生效的规则
@property(nonatomic, assign) CFRunLoopRef clientRunLoop;    // 请求所在的runloop
@property(nonatomic, assign, getter=isStop) BOOL stop;
@end

@implementation DBXStubsURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    DBXStubsRule *stubRule = [DBXStubs findMatchStubForRequest:request];
    if (stubRule) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    DBXStubsURLProtocol *proto = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    proto.stubRule = [DBXStubs findMatchStubForRequest:request];
    return proto;
}

- (void)startLoading {
    self.clientRunLoop = CFRunLoopGetCurrent();
    NSURLRequest *request = self.request;
    id<NSURLProtocolClient> client = self.client;
    if (!self.stubRule) {
        NSError *error = [NSError errorWithDomain:@"DBXStubsError" code:-1 userInfo:@{
            NSLocalizedFailureReasonErrorKey : @"Stub has been removed BEFORE the response had time to be sent.",
            NSURLErrorFailingURLErrorKey : request.URL
        }];
        [client URLProtocol:self didFailWithError:error];
        return;
    }
    DBXStubsResponse *response = self.stubRule.responseBlock(request);
    if (response.error) {
        [self executeOnClientRunLoopAfterDelay:response.responseTime block:^{
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
        if (self.isStop) {
            return;
        }
        // 发头信息
        [client URLProtocol:self didReceiveResponse:urlResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        if (response.inputStream.streamStatus == NSStreamStatusNotOpen) {
            [response.inputStream open];
        }
        if (response.dataSize <= 0 || !response.inputStream.hasBytesAvailable) {
            [self executeOnClientRunLoopAfterDelay:response.responseTime block:^{
                [response.inputStream close];
                if (!self.isStop) {
                    [client URLProtocol:self didFailWithError:response.error];
                }
            }];
            return;
        }
        DBXStubsTimingInfo *timingInfo = [self getTimeInfoFromResponse:response];
        [self streamDataForClient:client fromStream:response.inputStream timingInfo:timingInfo completion:^(NSError *error) {
            [response.inputStream close];
            if (error) {
                [client URLProtocol:self didFailWithError:error];
            } else {
                [client URLProtocolDidFinishLoading:self];
            }
        }];
    }];
}

- (void)streamDataForClient:(id<NSURLProtocolClient>)client fromStream:(NSInputStream*)inputStream timingInfo:(DBXStubsTimingInfo *)timingInfo completion:(void(^)(NSError * error))completion {
    if (!self.isStop && inputStream.hasBytesAvailable) {
        double cumulativeChunkSizeAfterRead = timingInfo.cumulativeChunkSize + timingInfo.slotSize;
        NSUInteger chunkSizeToRead = floor(cumulativeChunkSizeAfterRead) - floor(timingInfo.cumulativeChunkSize);
        timingInfo.cumulativeChunkSize = cumulativeChunkSizeAfterRead;
        
        if (chunkSizeToRead == 0) {
            [self executeOnClientRunLoopAfterDelay:timingInfo.slotTime block:^{
                [self streamDataForClient:client fromStream:inputStream
                               timingInfo:timingInfo completion:completion];
            }];
        } else {
            uint8_t* buffer = (uint8_t*)malloc(sizeof(uint8_t)*chunkSizeToRead);
            NSInteger bytesRead = [inputStream read:buffer maxLength:chunkSizeToRead];
            if (bytesRead > 0)
            {
                NSData * data = [NSData dataWithBytes:buffer length:bytesRead];
                [self executeOnClientRunLoopAfterDelay:((double)bytesRead / (double)chunkSizeToRead) * timingInfo.slotTime block:^{
                    [client URLProtocol:self didLoadData:data];
                    [self streamDataForClient:client fromStream:inputStream
                                   timingInfo:timingInfo completion:completion];
                }];
            } else {
                if (completion)
                {
                    completion(inputStream.streamError);
                }
            }
            free(buffer);
        }
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

- (DBXStubsTimingInfo *)getTimeInfoFromResponse:(DBXStubsResponse *)response {
    DBXStubsTimingInfo *timing = [[DBXStubsTimingInfo alloc] init];
    if (response.responseTime < 0) {
        timing.slotSize = fabs(response.responseTime) * 1000 * timing.slotTime;
    } else if (response.responseTime < kslotTime) {
        timing.slotSize = response.dataSize;
        timing.slotTime = response.requestTime;
    } else {
        timing.slotSize = ((response.dataSize/response.responseTime) * timing.slotTime);
    }
    return timing;
}

- (void)stopLoading {
    self.stop = YES;
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
