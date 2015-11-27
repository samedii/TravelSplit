//
//  Currency.m
//  splitter
//
//  Created by Direwolf on 2012-01-12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import "Money.h"


@implementation Money

@synthesize amount, relativeValue, currency;

+(Money*)moneyWithAmount:(float)am relativeCurrency:(float)rel andCurrency:(NSString *)aCurrency {
	Money* m = [ [ Money alloc ] init ];
	m.amount = am;
	m.relativeValue = rel;
    m.currency = aCurrency;
	
	return [ m autorelease ];
}

+(Money*)moneyWithAmount:(float)am relativeCurrency:(float)rel {
    
    NSLog(@"Warning: Use of deprecated init for money");
    
	Money* m = [ [ Money alloc ] init ];
	m.amount = am;
	m.relativeValue = rel;
    m.currency = @"";
	
	return [ m autorelease ];
}

-(Money*) sumWith:(Money*)cur {
    
	amount += cur.amount * relativeValue / cur.relativeValue;
	
	return self;
}

-(Money*) subtract:(Money*)cur {
	amount -= cur.amount * relativeValue / cur.relativeValue;
	
	return self;
}

-(Money*) sameCurrencyDifferentAmount:(float)am {
	return [ Money moneyWithAmount:am relativeCurrency:relativeValue ];
}

-(float)floatValue {
    return amount;
}

-(int)intValue {
    return round(amount);
}

-(NSString*)stringValue {
    return [NSString stringWithFormat:@"%i %@", [self intValue], currency];
}

-(float)trueValue {
    if(relativeValue == 0) {
        if(amount != 0) {
            NSLog(@"Error: Relative value set to 0");
        }
        return 0;
    }
    
    return amount/relativeValue;
}

-(NSNumber*)getNumber {
    return [NSNumber numberWithFloat:amount];
}


-(id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self)
    {
        amount = [coder decodeFloatForKey:@"MoneyAmount"];
        relativeValue = [coder decodeFloatForKey:@"MoneyReAmount"];
        currency = [coder decodeObjectForKey:@"MoneyCurrency"];
        [currency retain];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    //[super encodeWithCoder:coder];
    
    [coder encodeFloat:amount forKey:@"MoneyAmount"];
    [coder encodeFloat:relativeValue forKey:@"MoneyReAmount"];
    [coder encodeObject:currency forKey:@"MoneyCurrency"];
    
}

-(void)dealloc {
    [currency release];
    [super dealloc];
}

-(BOOL)isEqual:(id)object {
    if([object isKindOfClass:[Money class]]) {
        if(fabsf(((Money*)object).amount - self.amount) < 0.001 && fabsf(((Money*)object).relativeValue - self.relativeValue) < 0.001) {
           return YES;
        }
    }
    return NO;
}


@end
