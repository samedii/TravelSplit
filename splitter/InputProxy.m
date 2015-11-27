//
//  InputProxy.m
//  splitter
//
//  Created by Richard Hermanson on 20/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "InputProxy.h"


@implementation InputProxy

@synthesize name;

-(id)initWithUser:(NSString *)aName andTarget:(id<InputProxyListener>)aTarget
{
    self = [super init];
    if(self)
    {
        target = aTarget;
        name = aName;
        [name retain];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [target textFieldShouldReturn:textField forName:name];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return [target textField:textField shouldChangeCharactersInRange:range replacementString:string forName:name];
}



-(void)dealloc {
    [name release];
    [super dealloc];
}


@end
