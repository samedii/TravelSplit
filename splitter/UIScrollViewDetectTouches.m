//
//  UIScrollViewDetectTouches.m
//  splitter
//
//  Created by Richard Hermanson on 15/03/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import "UIScrollViewDetectTouches.h"


@implementation UIScrollViewDetectTouches

-(id)initWithFrame:(CGRect)aFrame andListener:(id)aListener {
    self = [self initWithFrame:aFrame];
    if(self) {
        listener = aListener;
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [listener detectedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event];
}

@end
