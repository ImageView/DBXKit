//
//  DBXListUpdateTransactable.h
//  DBXKit
//
//  Created by 罗俊宇 on 2025/10/18.
//  Copyright © 2025 DBX. All rights reserved.
//

#ifndef DBXListUpdateTransactable_h
#define DBXListUpdateTransactable_h

@protocol DBXListUpdateTransactable <NSObject>

- (void)begin;
- (BOOL)cancel;
@end
#endif /* DBXListUpdateTransactable_h */
