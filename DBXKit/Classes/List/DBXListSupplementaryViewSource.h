//
//  DBXListSupplementaryViewSource.h
//  DBXKit
//
//  Created by 调包侠 on 2025/7/29.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListSupplementaryViewSource_h
#define DBXListSupplementaryViewSource_h

// 补充视图代理
@protocol DBXListSupplementaryViewSource <NSObject>

- (CGSize)supplementaryViewReferenceSizeOfKind:(NSString *)elementKind;

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind;

@end
#endif /* DBXListSupplementaryViewSource_h */
