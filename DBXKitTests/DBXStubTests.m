//
//  DBXStubsTests.m
//  DBXKitTests
//
//  Created by 罗俊宇 on 2025/3/29.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DBXStubs.h"

@interface DBXStubTests : XCTestCase

@end

@implementation DBXStubTests

- (void)setUp {
    [DBXStubs activateStub];
    [DBXStubs stubMatching:^BOOL(NSURLRequest * _Nonnull request) {
        if ([request.URL.absoluteString containsString:@"opensource.apple"] || [request.URL.absoluteString containsString:@"https.com"]) {
            return YES;
        }
        return NO;
    } responseWith:^DBXStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString *fileName = [request.URL.absoluteString containsString:@"pdf"] ? @"testforStub.pdf" : @"StubsJsonTests.geojson";
        NSString *path = DBXPathForFile(fileName, self.class);
        DBXStubsResponse *response = [DBXStubsResponse responseWithFilePath:path statusCode:200 headers:nil];
        response.responseTime = DBXStubsDownloadSpeed3GPlus;
        return response;
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDoubleActivateStub {
    [DBXStubs activateStub];
}

// 测试开启协议后自动把自定义协议插入到NSURLSessionConfiguration中，并且在关闭协议后不再插入
- (void)testInsertProtocolToSecssionConfiguration {
    NSURLSessionConfiguration *testConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *testSession = [NSURLSession sessionWithConfiguration:testConfig];
    [DBXStubs deactivateStub];
    NSURLSessionConfiguration *testConfig1 = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSessionDataTask *task = [testSession dataTaskWithURL:[NSURL URLWithString:@"https.com"]];
    [task resume];
}

//- (void)testText {
//    XCTestExpectation *expect = [self expectationWithDescription:@"请求完成"];
//    NSString* urlString = @"http://www.opensource.apple.com/source/Git/Git-26/src/git-htmldocs/git-commit.txt?txt";
//    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    
//    // This is a very handy way to send an asynchronous method, but only available in iOS5+
//    [NSURLConnection sendAsynchronousRequest:req
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse* resp, NSData* data, NSError* error) {
//        NSString* receivedText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        NSLog(@"result = %@", receivedText);
//        [expect fulfill];
//    }];
//    [self waitForExpectations:@[expect]];
//}

//- (void)testBigFile {
//    XCTestExpectation *expect = [self expectationWithDescription:@"请求完成"];
//    NSString* urlString = @"http://www.opensource.apple.com/source/Git/Git-26/src/git-htmldocs/git-commit.txt?pdf";
//    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    
//    // This is a very handy way to send an asynchronous method, but only available in iOS5+
//    [NSURLConnection sendAsynchronousRequest:req
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse* resp, NSData* data, NSError* error) {
//        NSLog(@"bigfile = %ld", data.length);
//        [expect fulfill];
//    }];
//    [self waitForExpectations:@[expect]];
//}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
