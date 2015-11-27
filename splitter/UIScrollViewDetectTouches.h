//
//  UIScrollViewDetectTouches.h
//  splitter
//
//  Created by Richard Hermanson on 15/03/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIScrollViewDetectedTouchesProtocol <NSObject>

-(void)detectedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface UIScrollViewDetectTouches : UIScrollView {
    id<UIScrollViewDetectedTouchesProtocol> listener;
}

-(id)initWithFrame:(CGRect)aFrame andListener:(id)aListener;

@end
