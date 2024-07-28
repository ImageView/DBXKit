//
//  MnaDashedRectView.m
//  MnaDebuggingOnLine
//
//  Created by 罗俊宇 on 2024/7/28.
//

#import "MnaDashedRectView.h"

@implementation MnaDashedRectView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    // 虚线的样式
    CGFloat dashPattern[] = {10, 6}; // 10是线的长度，6是每段空白的长度
    CGContextSetLineDash(context, 0, dashPattern, 2);
    CGRect rectangle = self.bounds;
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
}

@end
