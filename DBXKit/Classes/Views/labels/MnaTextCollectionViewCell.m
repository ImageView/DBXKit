//
//  MnaTextCollectionViewCell.m
//  MnamatrixVideo
//
//  Created by 罗俊宇 on 2020/9/2.
//  Copyright © 2020 Tecent. All rights reserved.
//

#import "MnaTextCollectionViewCell.h"

// 纯文本的cell
@implementation MnaTextCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
}

- (void)initialSubViews {
    [self addSubview:self.titleLabel];
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

@end
