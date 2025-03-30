//
//  DBXStubTests.m
//  DBXKitTests
//
//  Created by 罗俊宇 on 2025/3/29.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DBXStub.h"
#import "DBXStubsResponse.h"

@interface DBXStubTests : XCTestCase

@end

@implementation DBXStubTests

- (void)setUp {
    [DBXStub activateStub];
    [DBXStub stubMatching:^BOOL(NSURLRequest * _Nonnull requeset) {
        if ([requeset.URL.absoluteString containsString:@"opensource.apple"]) {
            return YES;
        }
        return NO;
    } responseWith:^DBXStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        DBXStubsResponse *response = [[DBXStubsResponse alloc] init];
        response.statusCode = 200;
        
        NSBundle* bundle = [NSBundle bundleForClass:self.class];
        NSString *path = [bundle pathForResource:@"StubsJsonTests"
                                ofType:@"geojson"];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        NSNumber *fileSize;
        NSError *error;
        const BOOL success __unused = [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error];
        NSInputStream *inputStream = [NSInputStream inputStreamWithURL:fileURL];
        response.inputStream = inputStream;
        response.dataSize = fileSize.longLongValue;

        response.httpHeaders = @{
            @"Content-Length" : [NSString stringWithFormat:@"%llu", response.dataSize],
            @"Content-Type" : @"text/plain"
        };
        response.requestTime = 0;
        response.responseTime = 0;
        return response;
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    NSString* urlString = @"http://www.opensource.apple.com/source/Git/Git-26/src/git-htmldocs/git-commit.txt?txt";
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    // This is a very handy way to send an asynchronous method, but only available in iOS5+
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* resp, NSData* data, NSError* error) {
        NSString* receivedText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"result = %@", receivedText);
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
