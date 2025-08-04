//
//  DBXListDiffable.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/8/3.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListDiffable_h
#define DBXListDiffable_h

// 差异化对象需要完成本协议
@protocol DBXListDiffable <NSObject>
// 唯一标识符
- (id)diffIdentifier;
// 比对函数，用来判断当前obj是否发生变更
- (BOOL)isEqualToDiffObject:(id <DBXListDiffable>)obj;

@end

#endif /* DBXListDiffable_h */
