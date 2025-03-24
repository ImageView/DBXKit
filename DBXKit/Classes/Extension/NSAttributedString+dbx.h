//
//  NSAttributedString+dbx.h
//  DBXKit
//
//  Created by 罗俊宇 on 2023/9/28.
//  Copyright © 2023 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (dbx)

/// 富文本填充Attributes
/// - Parameters:
///   - attrs: 要填充的Attributes
///   - delimiter: 分隔符
- (instancetype)dbx_addAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs delimiter:(NSString *)delimiter;
@end

@interface NSString (dbx)
- (NSString *)dbx_beginDelimiter;
- (NSString *)dbx_endDelimiter;
@end

NS_ASSUME_NONNULL_END
