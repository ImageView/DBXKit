//
//  DBXStubsResponse.m
//  DBXKit
//
//  Created by 调包侠 on 2025/3/25.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXStubsResponse.h"

const double DBXStubsDownloadSpeed1KBPS         = -8 / 8;       // 1 KB/s
const double DBXStubsDownloadSpeedSLOW          = -12 / 8;      // 1.5 KB/s
const double DBXStubsDownloadSpeedGPRS          = -56 / 8;      // 7 KB/s
const double DBXStubsDownloadSpeedEDGE          = -128 / 8;     // 16 KB/s
const double DBXStubsDownloadSpeed3G            = -3200 / 8;    // 400 KB/s
const double DBXStubsDownloadSpeed3GPlus        = -7200 / 8;    // 900 KB/s
const double DBXStubsDownloadSpeed4G            = -50000 / 8;   // 6250 KB/s
const double DBXStubsDownloadSpeed4GPlus        = -100000 / 8;  // 12500 KB/s
const double DBXStubsDownloadSpeed5G            = -500000 / 8;  // 62500 KB/s
const double DBXStubsDownloadSpeed5GUWB         = -1000000 / 8; // 125000 KB/s
const double DBXStubsDownloadSpeedWifiLegacy    = -12000 / 8;   // 1500 KB/s
const double DBXStubsDownloadSpeedWifi5         = -600000 / 8;  // 75000 KB/s
const double DBXStubsDownloadSpeedWifi6         = -1200000 / 8; // 150000 KB/s

@implementation DBXStubsResponse

+ (instancetype)responseWithJson:(NSString *)jsonString
                      statusCode:(int)statusCode
                         headers:(nullable NSDictionary*)httpHeaders {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [self responseWithData:data statusCode:statusCode headers:httpHeaders];
}

+ (instancetype)responseWithFilePath:(NSString *)filePath
                          statusCode:(int)statusCode
                             headers:(nullable NSDictionary*)httpHeaders {
    NSURL *fileURL = filePath ? [NSURL fileURLWithPath:filePath] : nil;
    if (!fileURL) {
        return [self responseWithInputStream:[NSInputStream inputStreamWithData:[NSData data]] dataSize:0 statusCode:statusCode headers:httpHeaders];
    }
    NSNumber *fileSizeNum = nil;
    BOOL succ = [fileURL getResourceValue:&fileSizeNum forKey:NSURLFileSizeKey error:nil];
    NSAssert(fileSizeNum && succ, @"Couldn't get the file size for URL");
    return [self responseWithInputStream:[NSInputStream inputStreamWithURL:fileURL] dataSize:fileSizeNum.unsignedLongLongValue statusCode:statusCode headers:httpHeaders];
}

+ (instancetype)responseWithData:(NSData*)data
                      statusCode:(int)statusCode
                         headers:(nullable NSDictionary*)httpHeaders {
    NSInputStream* inputStream = [NSInputStream inputStreamWithData:data?:[NSData data]];
    return [self responseWithInputStream:inputStream dataSize:data.length statusCode:statusCode headers:httpHeaders];
}

+ (instancetype)responseWithInputStream:(NSInputStream*)inputStream
                               dataSize:(unsigned long long)dataSize
                             statusCode:(int)statusCode
                                headers:(nullable NSDictionary*)httpHeader {
    DBXStubsResponse *response = [[DBXStubsResponse alloc] initWithInputStream:inputStream dataSize:dataSize statusCode:statusCode headers:httpHeader];
    return response;
}

- (instancetype)initWithInputStream:(NSInputStream*)inputStream
                          dataSize:(unsigned long long)dataSize
                        statusCode:(int)statusCode
                           headers:(nullable NSDictionary*)httpHeader {
    self = [super init];
    if (self)
    {
        _inputStream = inputStream;
        _dataSize = dataSize;
        _statusCode = statusCode;
        _requestTime = 0.5;
        _responseTime = 0.3;
        
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:httpHeader];
        if (!headers[@"Content-Length"]) {
            headers[@"Content-Length"] = [NSString stringWithFormat:@"%llu", _dataSize];
        }
        if (!headers[@"Content-Type"]) {
            headers[@"Content-Type"] = @"application/json;encoding=utf-8";
        }
        _httpHeaders = [NSDictionary dictionaryWithDictionary:headers];
    }
    return self;
}

@end
