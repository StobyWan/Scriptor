//
//  CustomAccessoryView.m
//  Scriptor
//
//  Created by Bryan Stober on 1/13/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "CustomAccessoryView.h"
#define PADDING 4.f

@implementation CustomAccessoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(context, 3.f);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextMoveToPoint(context, PADDING, PADDING);
    CGContextAddLineToPoint(context, self.frame.size.width - PADDING, self.frame.size.height/2);
    CGContextAddLineToPoint(context, PADDING, self.frame.size.height - PADDING);
    CGContextStrokePath(context);
}

@end
