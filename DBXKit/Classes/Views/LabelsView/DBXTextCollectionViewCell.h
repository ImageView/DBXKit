//
//  DBXTextCollectionViewCell.h
//  MnamatrixVideo
//
//  Created by 调包侠 on 2020/9/2.
//  Copyright © 2020 Tecent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 纯文本的cell
@interface DBXTextCollectionViewCell : UICollectionViewCell

// cell文本组件
@property (nonatomic, strong) UILabel *titleLabel;
// 文本颜色
@property(nonatomic, strong) UIColor *textColor;

@end

// 纯图片的cell
@interface DBXImageCollectionViewCell : UICollectionViewCell

// cell图片组件
@property (nonatomic, strong) UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END
