//
//  DBXStubsResponse.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/3/25.
//  Copyright © 2025 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 模拟的返回对象
@interface DBXStubsResponse : NSObject

// 头
@property(nonatomic, copy) NSDictionary *httpHeaders;

// 错误吗
@property(nonatomic, assign) int statusCode;

// 大文件写入
@property(nonatomic, strong) NSInputStream *inputStream;

// 文件大小
@property(nonatomic, assign) unsigned long long dataSize;

// 请求时间
@property(nonatomic, assign) NSTimeInterval requestTime;

/** 
 设定服务器相应时间
 */
@property(nonatomic, assign) NSTimeInterval responseTime;

// 错误
@property(nonatomic, strong) NSError *error;

@end

NS_ASSUME_NONNULL_END
