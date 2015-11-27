//
//  IconProxy.h
//  splitter
//
//  Created by Richard Hermanson on 25/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol IconProxyListener

- (void) clicked: (id)sender;

@end


@interface IconProxy : NSObject {
    
    id sender;
    id<IconProxyListener> target;
    
}

-(id)initWithSender:(id)aSender andTarget:(id<IconProxyListener>)aTarget;

-(void)clicked;

@end
