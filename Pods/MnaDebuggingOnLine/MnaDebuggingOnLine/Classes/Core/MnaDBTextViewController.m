//
//  MnaDBTextViewController.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2021/12/16.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBTextViewController.h"
#import "MnaDBHelper.h"

@interface MnaDBTextViewController ()
// 文本视图
@property(nonatomic, strong) UITextView *textView;

@end

// 显示文本内容页面
@implementation MnaDBTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:14.];
    self.textView.textColor = [UIColor blackColor];
    [self.view addSubview:self.textView];
    
    if (self.content) {
        self.textView.text = self.content;
    } else if (self.path) {
        self.textView.text = [self loadContent];
    }
    self.textView.contentOffset = CGPointZero;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.textView.frame = self.view.bounds;
}

- (void)shareAction {
    if (self.path) {
        NSURL *url = [NSURL fileURLWithPath:self.path isDirectory:NO];
        if (url) {
            [MnaDBHelper showShareActivityWithItems:@[url]];
        }
    } else if (self.content) {
        [MnaDBHelper showShareActivityWithItems:@[self.content]];
    }
}

// 遍历编码类型，找出合适的编码格式
- (NSString *)loadContent {
    NSError *error = nil;
    NSString *content = [[NSString alloc] initWithContentsOfFile:self.path usedEncoding:nil error:&error];
    if (!error) {
        return content;
    }
    
    error = nil;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    content = [[NSString alloc] initWithContentsOfFile:self.path encoding:enc error:&error];
    if (!error) {
        return content;
    }
    
    error = nil;
    for (int i = 1; i <= 30; i++) {
        content = [[NSString alloc] initWithContentsOfFile:self.path encoding:i error:&error];
        if (!error) {
            return content;
        }
    }
    return nil;
}

@end
