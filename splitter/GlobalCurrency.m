//
//  GlobalCurrency.m
//  splitter
//
//  Created by Richard Hermanson on 29/01/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import "GlobalCurrency.h"

static NSString *currency;

@implementation GlobalCurrency

+(void)setup {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    currency = [prefs objectForKey:@"globalCur"];
   
    if(currency == nil) {
        currency = @"SEK";
    }
    
    [currency retain];
}

+(void)set:(NSString*)aCurrency {
    [currency release];
    currency = aCurrency;
    [currency retain];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    [prefs setObject:currency forKey:@"globalCur"];
    
    [prefs synchronize];
    
}

+(NSString*)get {
    return currency;
}

@end
