#import "Cell.h"
#import "CustomCellBackground.h"
#import "UIView+roundedCorners.h"

@implementation Cell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
        [self setRoundedCorners:UIRectCornerAllCorners radius:CGSizeMake(5.0f, 5.0f)];
        self.selectedBackgroundView = backgroundView;
    }
    return self;
}

@end
