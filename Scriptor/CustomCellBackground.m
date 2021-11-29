#import "CustomCellBackground.h"
#import "Constants.h"

@implementation CustomCellBackground

- (void)drawRect:(CGRect)rect
{
    // draw a rounded rect bezier path filled with blue
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(aRef);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0f];
    bezierPath.lineWidth = 5.0f;
    [SCRIPTOR_DARK_GREY setStroke];
    
    UIColor *fillColor = SCRIPTOR_BLUE;// color equivalent is #87ceeb
    [fillColor setFill];
    
    [bezierPath stroke];
    [bezierPath fill];
    CGContextRestoreGState(aRef);
}

@end
