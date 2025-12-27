//
//  NSObject+PropertyObserver.h
//  DBXKit
//
//  Created by 调包侠 on 2023/10/10.
//  Copyright © 2023 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PropertyObserver)

- (void)dbx_addObserverForKeyPath:(NSString *)keyPath valueChange:(void (^)(id _Nullable value))changedCallBack;

- (void)dbx_removeObserverForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
