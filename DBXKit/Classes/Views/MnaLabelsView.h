//
//  MnaLabelsView.h
//  MnaGameDetailModule
//
//  Created by 罗俊宇 on 2020/11/2.
//  Copyright © 2021 Mna. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MnaLabelsView;
@protocol MnaLabelsViewDelegate <NSObject>

- (void)labelsView:(MnaLabelsView *)labelsView didSelectItemAtIndex:(NSInteger)index;

@end

@protocol MnaLabelsViewUIDelegate <NSObject>

- (void)labelsView:(MnaLabelsView *)labelsView itemCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index;

@end

// 多标签类
@interface MnaLabelsView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

// 标签点击代理
@property (nonatomic, weak) id<MnaLabelsViewDelegate> delegate;
// 标签UI代理
@property (nonatomic, weak) id<MnaLabelsViewUIDelegate> UIDelegate;

// UI
@property (nonatomic, strong) UICollectionView *collectionView;

// 文字字体
@property (nonatomic, strong) UIFont *textFont;
// 文字颜色
@property (nonatomic, strong) UIColor *itemTextColor;

// default is UICollectionViewScrollDirectionVertical
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
//文字到边框的x轴的间距
@property(nonatomic, assign) NSInteger xSpace;
//文字到边框的y轴的间距
@property(nonatomic, assign) NSInteger ySpace;
//固定item大小，不设置则使用计算的
@property(nonatomic, assign) CGSize itemSize;
//标签数组
@property (nonatomic, copy) NSArray *labelsArray;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
