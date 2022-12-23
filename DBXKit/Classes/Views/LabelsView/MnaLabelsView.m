//
//  MnaLabelsView.m
//  MnaGameDetailModule
//
//  Created by DBX on 2020/11/2.
//  Copyright © 2021 Mna. All rights reserved.
//

#import "MnaLabelsView.h"
//#import <Masonry/Masonry.h>
#import "DBXTextCollectionViewCell.h"

static NSString *gLabelsTextCellIdentifi = @"kDBXTextCollectionViewCellCellKey";
static NSString *gLabelsImageCellIdentifi = @"kDBXImageCollectionViewCellCellKey";

@interface MnaLabelsView ()

@property(nonatomic, assign) MnaLabelsStyle style;
// Data
@property (nonatomic, strong) NSMutableDictionary *itemWidthCache; //宽度缓存
// 数据源
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

// 多标签类
@implementation MnaLabelsView

- (instancetype)init {
    return [self initWithStyle:MnaLabelsStyleText];
}

- (instancetype)initWithStyle:(MnaLabelsStyle)style {
    self = [super init];
    if (self) {
        _style = style;
        self.userInteractionEnabled = NO;
        if (style == MnaLabelsStyleText) {
            _itemWidthCache = [NSMutableDictionary dictionary];
        }
        _dataSource = [NSMutableArray array];
        _scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [self addSubview:self.collectionView];
        _xSpace = 7;
        _ySpace = 5;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

// 根据text计算item的宽度，并存储下来
- (CGFloat)storeItemWidthForText:(NSString *)text {
    if (self.itemSize.width > 0 && self.itemSize.height > 0) {
        return self.itemSize.width;
    }
    
    if (!text || text.length == 0) {
        return 0;
    }
    NSNumber *tempNum = [_itemWidthCache objectForKey:text];
    CGFloat width = tempNum.floatValue;
    if (!tempNum) {
        width = [text boundingRectWithSize:CGSizeMake(200, 22)
                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:@{
                                    NSFontAttributeName : self.textFont
                                } context:nil]
                    .size.width + self.xSpace * 2; // 14为增加的间距 左右各7
        [_itemWidthCache setObject:@(width) forKey:text];
    }
    return width;
}

- (void)setLabelsArray:(NSArray *)labelsArray {
    _labelsArray = labelsArray;
    self.dataSource = [NSMutableArray arrayWithArray:labelsArray];
}

#pragma mark - UICollectionViewDataSource
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 4);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 如果实现了代理，则直接使用代理
    if ([self.UIDelegate respondsToSelector:@selector(labelsView:sizeForItemAtIndex:)]) {
        return [self.UIDelegate labelsView:self sizeForItemAtIndex:indexPath.row];
    }
    if (self.style == MnaLabelsStyleImage) {
//        NSAssert(YES, @"请设置itemSize");
        return self.itemSize;
    }
    NSString *text = _dataSource[indexPath.row];
    CGFloat itemWidth = self.itemSize.width > 0 ? self.itemSize.width : [self storeItemWidthForText:text];
    if (self.accessoryPadding) {
        UIImage *accessImg = self.accessoryPadding(indexPath.row);
        itemWidth += accessImg.size.width;
    }
    CGFloat itemHeight = self.itemSize.height > 0
    ? self.itemSize.height
    : MIN(self.textFont.pointSize + self.ySpace * 2, CGRectGetHeight(self.frame));
    return CGSizeMake(itemWidth, itemHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.style == MnaLabelsStyleImage) {
        DBXImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:gLabelsImageCellIdentifi forIndexPath:indexPath];
        NSString *imgName = _dataSource[indexPath.row];
        if (self.imageSetter) {
            self.imageSetter(cell.imageView, imgName);
        } else {
            cell.imageView.image = [UIImage imageNamed:imgName];
        }
        if ([_UIDelegate respondsToSelector:@selector(labelsView:itemCell:atIndex:)]) {
            [_UIDelegate labelsView:self itemCell:cell atIndex:indexPath.row];
        }
        return cell;
    } else {
        DBXTextCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:gLabelsTextCellIdentifi forIndexPath:indexPath];
        cell.textColor = _itemTextColor ?: [UIColor whiteColor];
        cell.titleLabel.font = self.textFont;
        cell.titleLabel.text = _dataSource[indexPath.row];
        if (self.accessoryPadding) {
            cell.accessoryView.image = self.accessoryPadding(indexPath.row);
        }
        if ([_UIDelegate respondsToSelector:@selector(labelsView:itemCell:atIndex:)]) {
            [_UIDelegate labelsView:self itemCell:cell atIndex:indexPath.row];
        }
        [self storeItemWidthForText:cell.titleLabel.text];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(labelsView:didSelectItemAtIndex:)]) {
        [_delegate labelsView:self didSelectItemAtIndex:indexPath.row];
    }
}

#pragma mark - Setter

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = scrollDirection;
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = self.scrollDirection;
        layout.minimumInteritemSpacing = 5; //不同section的竖直间距
        layout.minimumLineSpacing = 10;      //同一个section的水平间距
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[DBXTextCollectionViewCell class] forCellWithReuseIdentifier:gLabelsTextCellIdentifi];
        [_collectionView registerClass:[DBXImageCollectionViewCell class] forCellWithReuseIdentifier:gLabelsImageCellIdentifi];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (UIFont *)textFont
{
    if (!_textFont) {
        _textFont = [UIFont systemFontOfSize:11];
    }
    return _textFont;
}

@end
