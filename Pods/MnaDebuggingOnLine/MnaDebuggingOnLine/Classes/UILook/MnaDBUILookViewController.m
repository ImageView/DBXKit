//
//  MnaDBUILookViewController.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2021/11/15.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBUILookViewController.h"
#import "MnaDBLookViewDetailInfoViewController.h"
#import "MnaDBHelper.h"
#import "UIViewController+DB.h"
#import "UIView+DB.h"
#import <objc/runtime.h>
#import "MnaDashedRectView.h"

@interface MnaDBUILookViewController ()<MnaDBLookViewDetailInfoViewControllerDelegate>

// 选中的view
@property(nonatomic, strong) UIView *selectedView;
// 显示选中View的边框
@property(nonatomic, strong) UIView *selectedFrameView;
// 显示按钮的点击区域的的边框
@property(nonatomic, strong) MnaDashedRectView *buttonClickedFrameView;
// 关闭按钮
@property(nonatomic, strong) UIButton *dismissButton;
// 更换window层的按钮
@property(nonatomic, strong) UIButton *changeWindowButton;
// 内容信息
@property(nonatomic, strong) UILabel *infoLabel;

// 用于标记当前是否是双击
@property(nonatomic, assign) BOOL doubleTap;
// 双击时，需要忽略的view
@property(nonatomic, strong) UIView *ignoreView;
// 当前监视的window 下标
@property(nonatomic, assign) NSInteger windowIndex;

@end

// UI检查工具
@implementation MnaDBUILookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
    // 初始化起始下标
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (int i = 0; i<windows.count; i++) {
        UIWindow *window = windows[i];
        if (window == [[[UIApplication sharedApplication] delegate] window]) {
            self.windowIndex = i;
        }
    }
    [self setupSubviews];
}

- (void)setupSubviews {
    [self.view addSubview:self.selectedFrameView];
    [self.view addSubview:self.dismissButton];
    [self.view addSubview:self.infoLabel];
    [self.infoLabel addSubview:self.changeWindowButton];
    self.dismissButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 70, 30, 60, 60);
    self.infoLabel.frame = CGRectMake(10, CGRectGetMaxY(self.view.frame) - 280, CGRectGetWidth(self.view.frame) - 20, 280);
    self.changeWindowButton.frame = CGRectMake(CGRectGetWidth(self.infoLabel.frame) - 100, 0, 100, 40);
    [self.changeWindowButton setTitle:@"点我切换window\n(当前主Window)" forState:UIControlStateNormal];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.ignoreView = nil;
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    UIView *view = [self resolveTopViewWithPoint:point];
    if (self.doubleTap) {
        if (view) {
            BOOL hidden = view.hidden;
            view.hidden = YES;
            self.ignoreView = view;
            UIView *nextView = [self resolveTopViewWithPoint:point];
            view.hidden = hidden;
            self.ignoreView = nil;
            if (nextView) {
                view = nextView;
            }
        }
    }
    
    self.doubleTap = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.doubleTap = NO;
    });
    [self selectedAtView:view];
}

- (void)selectedAtView:(UIView *)view {
    self.selectedView = view;
    self.selectedFrameView.frame = [view.superview convertRect:view.frame toView:nil];
    
    NSString *addInfo = nil;
    NSString *className = NSStringFromClass(object_getClass(view));
    if ([className hasPrefix:@"_DBXClickedButton_"]) {
        SEL selector = NSSelectorFromString(@"dbx_extendedClikedArea");
        if ([view respondsToSelector:selector]) {
            CGRect expandedRect = ((CGRect (*)(id, SEL))[view methodForSelector:selector])(view, selector);
            self.buttonClickedFrameView.hidden = NO;
            self.buttonClickedFrameView.frame = [view convertRect:expandedRect toView:nil];
            addInfo = [NSString stringWithFormat:@"按钮点击区域(x:%.1f  y:%.1f  宽:%.1f  高:%.1f), ",
                       expandedRect.origin.x,
                       expandedRect.origin.y,
                       expandedRect.size.width,
                       expandedRect.size.height];
        }
    } else {
        _buttonClickedFrameView.hidden = YES;
    }
    [self showSelectedViewInfo:view additionalInfo:addInfo];

}

// 拿到点击位置的最顶层View
- (UIView *)resolveTopViewWithPoint:(CGPoint)point {
    UIView *view = nil;
    UIView *hitView = [self.currentWindow hitTest:point withEvent:nil].superview;
    CGPoint newP = [hitView convertPoint:point fromView:self.currentWindow];
    UIView *sub = [self getSubViewContainsPoint:newP inView:hitView];
    view = sub ?: hitView;
    return view;
}

- (UIView *)getSubViewContainsPoint:(CGPoint)point inView:(UIView *)view {
    NSArray *subAry = view.subviews;
    for (NSInteger i = subAry.count - 1; i >= 0; i--) {
        UIView *sub = [subAry objectAtIndex:i];
        if (sub == self.ignoreView || sub == self.view) continue;
        if (CGRectContainsPoint(sub.frame, point)) {
            CGPoint newP = [sub convertPoint:point fromView:view];
            UIView *subsub = [self getSubViewContainsPoint:newP inView:sub];
            if (subsub) {
                return subsub;
            } else {
                return sub;
            }
        }
    }
    return nil;
}

// 显示选中视图的信息
- (void)showSelectedViewInfo:(UIView *)view additionalInfo:(NSString *)additiInfo {
    NSMutableString *info = [NSMutableString string];
    [info appendFormat:@"%@【%@】\n", [view class], [[view dbx_viewController] class]];
    
    CGRect windowFrame = [view.superview convertRect:view.frame toView:nil];
    [info appendFormat:@"frame (x:%.1f  y:%.1f  宽:%.1f  高:%.1f)\n",
     view.frame.origin.x,
     view.frame.origin.y,
     view.frame.size.width,
     view.frame.size.height];
    
    [info appendFormat:@"相对屏幕位置 X:[%.1f,%.1f] Y:[%.1f,%.1f]\n",
     windowFrame.origin.x,
     CGRectGetMaxX(windowFrame),
     windowFrame.origin.y,
     CGRectGetMaxY(windowFrame)
    ];
    if (view.layer.borderWidth > 0) {
        [info appendFormat:@"Border Width: %.2f\n", view.layer.borderWidth];
        [info appendFormat:@"Border Color: %@\n", [self.class colorToString:view.layer.borderColor]];
    }
    [info appendFormat:@"Background Color: %@\n", [self.class colorToString:view.backgroundColor.CGColor]];

    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        [info appendFormat:@"Text: 【%@】\n",  label.text];
        [info appendFormat:@"Font: %@ %.1f\n",  label.font.fontName , label.font.pointSize];
        [info appendFormat:@"Color: %@\n", [self.class colorToString:label.textColor.CGColor]];
    } else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        NSURL *url = nil;
        if ([imageView respondsToSelector:@selector(sd_imageURL)]) {
            url = [imageView valueForKey:@"sd_imageURL"];
        }
        if (url.absoluteString) {
            [info appendFormat:@"ImageUrl: %@\n", url.absoluteString];
        } else {
            NSString *description = imageView.image.description;
            NSRange range = [description rangeOfString:@"named("];
            if (range.location != NSNotFound) {
                NSString *namePart = [description substringFromIndex:range.location + range.length];
                range = [namePart rangeOfString:@")"];
                if (range.location != NSNotFound) {
                    NSString *name = [namePart substringToIndex:range.location];
                    if ([name containsString:@":"]) {
                        NSArray *temNames = [name componentsSeparatedByString:@":"];
                        [info appendFormat:@"❤️ImageName: %@ (%@)\n", temNames.lastObject, temNames.firstObject];
                    } else {
                        [info appendFormat:@"❤️ImageName: %@\n", name];
                    }
                }
            }
        }
        if (imageView.image) {
            [info appendFormat:@"ImageSize: w%.1f h%.1f\n", imageView.image.size.width * imageView.image.scale, imageView.image.size.height * imageView.image.scale];
        }

    } else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        if (!UIEdgeInsetsEqualToEdgeInsets(btn.titleEdgeInsets, UIEdgeInsetsZero)) {
            [info appendFormat:@"TitleEdge: %.1f %.1f %.1f %.1f\n", btn.titleEdgeInsets.left, btn.titleEdgeInsets.top, btn.titleEdgeInsets.right, btn.titleEdgeInsets.bottom];
        }
        if (!UIEdgeInsetsEqualToEdgeInsets(btn.imageEdgeInsets, UIEdgeInsetsZero)) {
            [info appendFormat:@"ImageEdge: %.1f %.1f %.1f %.1f\n", btn.imageEdgeInsets.left, btn.imageEdgeInsets.top, btn.imageEdgeInsets.right, btn.imageEdgeInsets.bottom];
        }
    } else if ([view isKindOfClass:[UITextView class]]) {
        UITextView *label = (UITextView *)view;
        [info appendFormat:@"Text: %@\n", label.text];
        [info appendFormat:@"Font: %@ %.1f\n",  label.font.fontName , label.font.pointSize];
        [info appendFormat:@"Color: %@\n", [self.class colorToString:label.textColor.CGColor]];

    } else if ([view isKindOfClass:[UITextField class]]) {
        UITextField *label = (UITextField *)view;
        [info appendFormat:@"Text: %@\n", label.text];
        [info appendFormat:@"Font: %@ %.1f\n", label.font.fontName , label.font.pointSize];
        [info appendFormat:@"Color: %@\n", [self.class colorToString:label.textColor.CGColor]];

    }
    [info appendFormat:@"Corner Radius: %.2f\n", view.layer.cornerRadius];
    [info appendFormat:@"Opacity: %.2f\n", view.alpha];
    [info appendFormat:@"Hidden: %@\n", view.isHidden ? @"YES" : @"NO"];
    [info appendFormat:@"ClipsToBounds: %@\n", view.clipsToBounds ? @"YES" : @"NO"];
    [info appendFormat:@"UserInteractionEnabled: %@\n", view.userInteractionEnabled ? @"YES" : @"NO"];
    if (additiInfo) {
        [info appendFormat:@"%@\n", additiInfo];
    }
    [info appendFormat:@"\n长按分享，双击查看更多"];
    self.infoLabel.text = info;
}

- (void)infoDoubleTap:(id)sender {
    if (self.selectedView) {
        MnaDBLookViewDetailInfoViewController *detailVC = [[MnaDBLookViewDetailInfoViewController alloc] init];
        detailVC.targetObject = self.selectedView;
        detailVC.delegate = self;
        [detailVC showFromVC:self];
    }
}

- (void)infoLongTap:(id)sender {
    UILongPressGestureRecognizer *longTap = sender;
    if (longTap.state == UIGestureRecognizerStateBegan) {
        if (_infoLabel.text.length) {
            [MnaDBHelper showShareActivityWithItems:@[_infoLabel.text]];
        }
    }
}

- (void)changeWindow:(UIButton *)sender {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    if (self.windowIndex == windows.count-1) {
        self.windowIndex = 0;
    } else {
        self.windowIndex ++;
    }
    if ([self currentWindow] == [[[UIApplication sharedApplication] delegate] window]) {
        [self.changeWindowButton setTitle:@"点我切换window\n(当前主Window)" forState:UIControlStateNormal];
    } else {
        [self.changeWindowButton setTitle:[NSString stringWithFormat:@"点我切换window\n(当前Window %d)", (int)self.windowIndex] forState:UIControlStateNormal];
    }
}

- (UIWindow *)currentWindow {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    return windows[self.windowIndex];
}

#pragma mark - <MnaDBLookViewDetailInfoViewControllerDelegate>
- (void)lookViewDetailInfoViewController:(MnaDBLookViewDetailInfoViewController *)vc didShowSelectedView:(UIView *)view {
    [self selectedAtView:view];
}

#pragma mark - Class Method
+ (NSString *)colorToString:(CGColorRef)colorRef {
    if (!colorRef) {
        return @"<空>";
    }
    NSMutableString *colorInfo = [NSMutableString stringWithString:@"[RGBA "];
    const CGFloat *components = CGColorGetComponents(colorRef);
    NSUInteger componentsCount = CGColorGetNumberOfComponents(colorRef);
    NSMutableString *hexColor = [NSMutableString stringWithString:@"0x"];
    for (int i = 0; i < componentsCount; i++) {
        if (i == componentsCount - 1) {
            [colorInfo appendFormat:@"%.1f", components[i]];
        } else {
            [colorInfo appendFormat:@"%.1f,", components[i]];
        }
        
        [hexColor appendString:[self getHexByDecimal:components[i] * 255]];
    }
    [colorInfo appendString:@"] "];
    
    if (componentsCount == 4) {
        [colorInfo appendString:hexColor];
    }
    return colorInfo;
}

+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    if (decimal == 0) {
        return @"00";
    }
    NSString *hex = @"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i < 32; i++) {
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
            case 10:
                letter = @"A"; break;
            case 11:
                letter = @"B"; break;
            case 12:
                letter = @"C"; break;
            case 13:
                letter = @"D"; break;
            case 14:
                letter = @"E"; break;
            case 15:
                letter = @"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", (long)number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) break;
    }
    return hex.length > 1 ? hex : [@"0" stringByAppendingString:hex];
}

- (void)dismissAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Getter
- (UIView *)selectedFrameView
{
    if (!_selectedFrameView) {
        _selectedFrameView = [[UIView alloc] init];
        _selectedFrameView.layer.borderColor = [UIColor yellowColor].CGColor;
        _selectedFrameView.layer.borderWidth = 4 / [UIScreen mainScreen].scale;
    }
    return _selectedFrameView;
}

- (MnaDashedRectView *)buttonClickedFrameView {
    if (!_buttonClickedFrameView) {
        _buttonClickedFrameView = [[MnaDashedRectView alloc] init];
        [self.view addSubview:_buttonClickedFrameView];
        _buttonClickedFrameView.backgroundColor = [UIColor clearColor];
    }
    return _buttonClickedFrameView;
}

- (UIButton *)dismissButton
{
    if (!_dismissButton) {
        _dismissButton = [[UIButton alloc] init];
        [_dismissButton setImage:[MnaDBHelper imageWithName:@"icon_close"] forState:UIControlStateNormal];
        [_dismissButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
        [_dismissButton allowFollow];
    }
    return _dismissButton;
}

- (UILabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
        _infoLabel.textColor = [UIColor yellowColor];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.numberOfLines = 0;
        _infoLabel.userInteractionEnabled = YES;
        
        UILongPressGestureRecognizer *longTapGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(infoLongTap:)];
        [_infoLabel addGestureRecognizer:longTapGes];
        [_infoLabel allowFollow];
        UITapGestureRecognizer*doubleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoDoubleTap:)];
        doubleTapGes.numberOfTapsRequired = 2;
        [_infoLabel addGestureRecognizer:doubleTapGes];
        
    }
    return _infoLabel;
}

- (UIButton *)changeWindowButton {
    if (!_changeWindowButton) {
        _changeWindowButton = [[UIButton alloc] init];
//        _changeWindowButton.layer.borderColor = [UIColor whiteColor].CGColor;
//        _changeWindowButton.layer.borderWidth = 3;
        _changeWindowButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _changeWindowButton.titleLabel.numberOfLines = 2;
        [_changeWindowButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_changeWindowButton addTarget:self action:@selector(changeWindow:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeWindowButton;
}

@end
