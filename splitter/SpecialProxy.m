//
//  SpecialProxy.m
//  splitter
//
//  Created by Richard Hermanson on 07/04/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import "SpecialProxy.h"


@implementation SpecialProxy

@synthesize name, activated;

-(id)initWithUser:(NSString *)aName andTarget:(id<SpecialProxyListener>)aTarget
{
    self = [super init];
    if(self)
    {
        target = aTarget;
        name = aName;
        [name retain];
        
        activated = NO;
    }
    return self;
}

-(void)toggleEdit {
    [target toggleEditFor:name];
}

-(void)dealloc {
    [name release];
    [super dealloc];
}

@end
