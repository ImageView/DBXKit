//
//  DBXStubsResponse.h
//  DBXKit
//
//  Created by 调包侠 on 2025/3/25.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const double
DBXStubsDownloadSpeed1KBPS,     // 1 KB/s
DBXStubsDownloadSpeedSLOW,      // 1.5 KB/s
DBXStubsDownloadSpeedGPRS,      // 7 KB/s
DBXStubsDownloadSpeedEDGE,      // 16 KB/s
DBXStubsDownloadSpeed3G,        // 400 KB/s
DBXStubsDownloadSpeed3GPlus,    // 900 KB/s
DBXStubsDownloadSpeed4G,        // 6250 KB/s
DBXStubsDownloadSpeed4GPlus,    // 12500 KB/s
DBXStubsDownloadSpeed5G,        // 62500 KB/s
DBXStubsDownloadSpeed5GUWB,     // 125000 KB/s
DBXStubsDownloadSpeedWifiLegacy,// 1500 KB/s
DBXStubsDownloadSpeedWifi5,     // 75000 KB/s
DBXStubsDownloadSpeedWifi6;     // 150000 KB/s

// 模拟的返回对象
@interface DBXStubsResponse : NSObject

// 头
@property(nonatomic, copy) NSDictionary *httpHeaders;

// 错误吗
@property(nonatomic, assign) int statusCode;

// 文件写入
@property(nonatomic, strong) NSInputStream *inputStream;

// 文件大小
@property(nonatomic, assign) unsigned long long dataSize;

// 请求时间，默认 0.5
@property(nonatomic, assign) NSTimeInterval requestTime;

/** 
 设定服务器响应，默认 DBXStubsDownloadSpeedWifiLegacy
 >0时表示传输时间
 使用预设值如DBXStubsDownloadSpeed5G时，表示用5G的传输速度响应，可以用于模拟网速较差的情况
 */
@property(nonatomic, assign) NSTimeInterval responseTime;

// 错误
@property(nonatomic, strong) NSError *error;

// httpHeaders默认Content-Type为application/json;encoding=utf-8，可自行修改
+ (instancetype)responseWithJson:(NSString *)jsonString
                      statusCode:(int)statusCode
                         headers:(nullable NSDictionary*)httpHeaders;

+ (instancetype)responseWithFilePath:(NSString *)filePath
                          statusCode:(int)statusCode
                             headers:(nullable NSDictionary*)httpHeaders;

+ (instancetype)responseWithData:(NSData*)data
                      statusCode:(int)statusCode
                         headers:(nullable NSDictionary*)httpHeaders;

+ (instancetype)responseWithInputStream:(NSInputStream*)inputStream
                               dataSize:(unsigned long long)dataSize
                             statusCode:(int)statusCode
                                headers:(nullable NSDictionary*)httpHeader;

@end

NS_ASSUME_NONNULL_END
