//
//  BubbleView.m
//  splitter
//
//  Created by Richard Hermanson on 12/06/12.
//  Copyright (c) 2012 Jeanette Wrede. All rights reserved.
//

#import "BubbleView.h"

@implementation BubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)aRect
{
    // Drawing code
    UIImage* balloon;
    UIImage *bg;

    bg = [UIImage imageNamed:@"bubble.png"];
    balloon = [bg stretchableImageWithLeftCapWidth:15  topCapHeight:15];

    
    [balloon drawInRect: aRect];
    
    
}



@end
