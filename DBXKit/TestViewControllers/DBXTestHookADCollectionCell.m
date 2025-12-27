//
//  DBXTestHookADCollectionCell.m
//  DBXKit
//
//  Created by 调包侠 on 2025/7/31.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXTestHookADCollectionCell.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>

@interface DBXTestHookADCollectionCell ()


@end

@implementation DBXTestHookADCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont boldSystemFontOfSize:15];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}

@end

@implementation DBXTestADCollectionCell

@end
