//
//  MnaTextCollectionViewCell.h
//  MnamatrixVideo
//
//  Created by 罗俊宇 on 2020/9/2.
//  Copyright © 2020 Tecent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, MnaTextCollectionViewCellBorderType) {
    MnaTextCollectionViewCellBorderTypeNone,
    MnaTextCollectionViewCellBorderTypeCorner
};

// 纯文本的cell
@interface MnaTextCollectionViewCell : UICollectionViewCell

// cell文本组件
@property (nonatomic, strong) UILabel *titleLabel;
// 文本颜色
@property(nonatomic, strong) UIColor *textColor;

@end

NS_ASSUME_NONNULL_END
