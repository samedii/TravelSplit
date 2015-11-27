//
//  CurrencyRateFetcher.h
//  splitter
//
//  Created by Direwolf on 2012-01-12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Money.h"

@interface CurrencyRateFetcher : NSObject<NSXMLParserDelegate> {
	NSMutableDictionary* dict;
	NSDate* lastUpdate;
	bool error;//flag indicating if there was an error
}

@property (readonly) NSDate* lastUpdate;
@property (readonly) bool error;

-(bool) needsToFetch;



-(BOOL) containsCurrency:(NSString*)currency;
-(NSNumber*)getRateFor:(NSString*)currency;

-(Money*) money:(float)amount currency:(NSString*)currency;

//Do not use
-(NSDictionary*) getOldRates;
-(NSDictionary*) getCurrentRates;

-(Money*)emptyMoney;

@end
