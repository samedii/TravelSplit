//
//  CurrencyProxy.m
//  splitter
//
//  Created by Richard Hermanson on 29/01/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import "CurrencyProxy.h"


@implementation CurrencyProxy

@synthesize name;

-(id)initWithUser:(NSString *)aName andTarget:(id<CurrencyProxyListener>)aTarget
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
    return [target currencyTextFieldShouldReturn:textField forName:name];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Could possibly only allow currencies that we have
    return [target currencyTextField:textField shouldChangeCharactersInRange:range replacementString:string forName:name];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = nil;
}


@end
