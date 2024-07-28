//
//  MnaSandBoxItemCollectionViewCell.h
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2021/12/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MnaSandBoxItemCollectionViewCell;
@protocol MnaSandBoxItemCollectionViewCellDelegate <NSObject>

- (void)sandBoxItemCollectionViewCellLongPress:(MnaSandBoxItemCollectionViewCell *)cell;

@end
// 文件cell
@interface MnaSandBoxItemCollectionViewCell : UICollectionViewCell
// 代理
@property(nonatomic, weak) id <MnaSandBoxItemCollectionViewCellDelegate> delegate;
// 文件路径
@property(nonatomic, copy) NSString *filePath;
// 文本视图
@property(nonatomic, strong) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
