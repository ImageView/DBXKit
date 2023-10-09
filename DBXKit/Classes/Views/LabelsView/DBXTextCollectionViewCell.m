//
//  DBXTextCollectionViewCell.m
//  MnamatrixVideo
//
//  Created by DBX on 2020/9/2.
//  Copyright © 2020 Tecent. All rights reserved.
//

#import "DBXTextCollectionViewCell.h"

// 纯文本的cell
@implementation DBXTextCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat space = 0;
    if (_accessoryView) {
        _accessoryView.frame = CGRectMake(self.contentInsets.left, 0, _accessoryView.image.size.width, CGRectGetHeight(self.contentView.frame));
        space = self.accessorySpace;
    }
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_accessoryView.frame) + space, 0, CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(_accessoryView.frame) - space - self.contentInsets.right, CGRectGetHeight(self.contentView.frame));
}

- (void)initialSubViews {
    [self.contentView addSubview:self.titleLabel];
}

#pragma mark - Setter
- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.titleLabel.textColor = textColor;
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:12.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] init];
        _accessoryView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_accessoryView];
    }
    return _accessoryView;
}

@end


// 纯图片的cell
@implementation DBXImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = CGRectMake(self.contentInsets.left, self.contentInsets.top, CGRectGetWidth(self.bounds) - self.contentInsets.left - self.contentInsets.right, CGRectGetHeight(self.bounds) - self.contentInsets.top - self.contentInsets.bottom);
}

- (void)initialSubViews {
    [self addSubview:self.imageView];
}

#pragma mark - Setter

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

@end
