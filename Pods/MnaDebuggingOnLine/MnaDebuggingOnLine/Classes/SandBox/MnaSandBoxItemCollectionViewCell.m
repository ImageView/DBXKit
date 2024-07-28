//
//  MnaSandBoxItemCollectionViewCell.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2021/12/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaSandBoxItemCollectionViewCell.h"
#import "MnaDBHelper.h"

@interface MnaSandBoxItemCollectionViewCell ()

// 图片视图
@property(nonatomic, strong) UIImageView *iconImgView;
// 文件类型
@property(nonatomic, strong) UILabel *fileTypeLabel;
// 文件大小
@property(nonatomic, strong) UILabel *fileSizeLabel;
@end
// 文件cell
@implementation MnaSandBoxItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.fileTypeLabel];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.fileSizeLabel];
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self.contentView addGestureRecognizer:longGes];
}

- (void)longGesture:(UILongPressGestureRecognizer *)longGes {
    if (longGes.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(sandBoxItemCollectionViewCellLongPress:)]) {
            [self.delegate sandBoxItemCollectionViewCellLongPress:self];
        }
    }
}

- (void)layoutSubviews {
    CGSize selfSize = self.bounds.size;
//    self.iconImgView.frame = CGRectMake(selfSize.width/4, 0, selfSize.width/2, selfSize.height - 40);
//    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.iconImgView.frame), selfSize.width, 40);
    self.fileTypeLabel.frame = CGRectMake(0, 0, selfSize.width, selfSize.height - 40 - 12);
    self.iconImgView.frame = self.fileTypeLabel.frame;
    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.fileTypeLabel.frame), selfSize.width, 40);
    self.fileSizeLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), selfSize.width, 12);
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    NSString *fileType = filePath.pathExtension;
    if (!fileType || fileType.length == 0) {
        self.iconImgView.hidden = NO;
    } else {
        self.iconImgView.hidden = YES;
        self.fileTypeLabel.text = fileType;
    }
    self.fileTypeLabel.hidden = !self.iconImgView.isHidden;
    
    self.fileSizeLabel.text = [self fileSizeUnit:[self folderSizeAtPath:filePath]];
}

- (unsigned long long)folderSizeAtPath:(NSString *)folderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long folderSize = [[fileManager attributesOfItemAtPath:folderPath error:nil] fileSize];

    while ((fileName = [filesEnumerator nextObject])) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        folderSize += [fileAttributes fileSize];
    }

    return folderSize;
}

/// 文件大小单位显示
- (NSString *)fileSizeUnit:(unsigned long long)size {
    NSString *result;
    if (size > (1024.0 * 1024.0 * 1024.0)) {
        result = [NSString stringWithFormat:@"%.2fGB", size / (1024.0 * 1024.0 * 1024.0)];
    } else if (size > (1024.0 * 1024.0)) {
        result = [NSString stringWithFormat:@"%.2fMB", size / (1024.0 * 1024.0)];
    } else if (size > 1024.0) {
        result = [NSString stringWithFormat:@"%.2fKB", size / 1024.0];
    } else {
        result = [NSString stringWithFormat:@"%lluB", size];
    }
    return result;
}

#pragma mark - Getter
- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeCenter;
        _iconImgView.image = [MnaDBHelper imageWithName:@"icon_directory"];
    }
    return _iconImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.minimumScaleFactor = 0.5;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}

- (UILabel *)fileTypeLabel {
    if (!_fileTypeLabel) {
        _fileTypeLabel = [[UILabel alloc] init];
        _fileTypeLabel.textColor = [UIColor colorWithRed:219.0/255 green:112.0/255 blue:147/255.0 alpha:1];
        _fileTypeLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBlack];
        _fileTypeLabel.textAlignment = NSTextAlignmentCenter;
        _fileTypeLabel.numberOfLines = 0;
        _fileTypeLabel.minimumScaleFactor = 0.5;
        _fileTypeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _fileTypeLabel;
}

- (UILabel *)fileSizeLabel {
    if (!_fileSizeLabel) {
        _fileSizeLabel = [[UILabel alloc] init];
        _fileSizeLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        _fileSizeLabel.textColor = [UIColor colorWithRed:100.0/255 green:149.0/255 blue:237/255.0 alpha:1];
        _fileSizeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _fileSizeLabel;
}
@end
