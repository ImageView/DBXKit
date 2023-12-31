//
//  MnaLabelsView.h
//  MnaGameDetailModule
//
//  Created by DBX on 2020/11/2.
//  Copyright © 2021 Mna. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MnaLabelsStyle) {
    MnaLabelsStyleText,
    MnaLabelsStyleImage
};

@class MnaLabelsView;
@protocol MnaLabelsViewDelegate <NSObject>

@optional
- (void)labelsView:(MnaLabelsView *)labelsView didSelectItemAtIndex:(NSInteger)index;

@end

@protocol MnaLabelsViewUIDelegate <NSObject>

@optional
- (void)labelsView:(MnaLabelsView *)labelsView itemCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index;
// 返回item大小
- (CGSize)labelsView:(MnaLabelsView *)labelsView sizeForItemAtIndex:(NSInteger)index;

@end

// 多标签类
@interface MnaLabelsView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

// 标签点击代理
@property (nonatomic, weak) id<MnaLabelsViewDelegate> delegate;
// 标签UI代理
@property (nonatomic, weak) id<MnaLabelsViewUIDelegate> UIDelegate;

// UI
@property (nonatomic, strong) UICollectionView *collectionView;

// default is UICollectionViewScrollDirectionHorizontal
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;

/// 单个item的内容内边距
/// 文本时默认为(5, 7, 5, 7)，图片默认(0, 0, 0, 0)
@property(nonatomic, assign) UIEdgeInsets itemInsets;

#pragma mark - 以下属性 for MnaLabelsStyleText
// 文字字体
@property (nonatomic, strong) UIFont *textFont;
// 文字颜色
@property (nonatomic, strong) UIColor *itemTextColor;
// 文本内容的附件头,返回附件头的图片
@property (nonatomic, copy) UIImage * (^accessoryPadding)(NSInteger index);
/// 附件头和文本的间距，默认4
@property(nonatomic, assign) CGFloat accessorySpace;
#pragma mark - 以下属性 for MnaLabelsStyleImage
// 用于给ImageView设置img，主要是设置图片的url
@property(nonatomic, copy) void (^imageSetter)(UIImageView *imageView, NSString *imgContent);

/// 固定item大小
/// MnaLabelsStyleText下，不设置则使用计算的，itemsize的width和height分别计算，可以设置单项为0
/// MnaLabelsStyleImage下必须设置值
/// 实现代理方法（labelsView:sizeForItemAtIndex:）的话此属性无效
@property(nonatomic, assign) CGSize itemSize;
//标签数组
@property (nonatomic, copy) NSArray *labelsArray;

- (instancetype)initWithStyle:(MnaLabelsStyle)style;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
