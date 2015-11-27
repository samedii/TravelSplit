//
//  IconProxy.m
//  splitter
//
//  Created by Richard Hermanson on 25/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "IconProxy.h"


@implementation IconProxy

-(id)initWithSender:(id)aSender andTarget:(id)aTarget
{
    self = [super init];
    if(self)
    {
        sender = aSender;
        target = aTarget;
    }
    return self;
}

-(void)clicked
{
    [target clicked:sender];
}

@end
