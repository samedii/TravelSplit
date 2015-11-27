//
//  Currency.h
//  splitter
//
//  Created by Direwolf on 2012-01-12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

//represents an amount of money in a specific currency
@interface Money : NSObject <NSCoding> {
	
	//the amount of 
	float amount;
	
	//the relative value of this specific currency
	float relativeValue;
    
    NSString *currency;

}

@property (assign) float amount, relativeValue;
@property (retain) NSString *currency;

//relativeCurrency value of 1.0 = EUR
+(Money*)moneyWithAmount:(float)amount relativeCurrency:(float)rel;
+(Money*)moneyWithAmount:(float)amount relativeCurrency:(float)rel andCurrency:(NSString*)aCurrency;

//returns 'self' so that it is easier to summations, if one wants to.
//e.g
//[ [ m1 sumWith:m2 ] sumWith:m3 ];
//etc
-(Money*) sumWith:(Money*)cur;
-(Money*) subtract:(Money*)cur;

-(Money*) sameCurrencyDifferentAmount:(float)amount;

-(float) floatValue;
-(int) intValue;
-(NSString*)stringValue;

-(NSNumber*) getNumber;

-(float) trueValue;

@end
