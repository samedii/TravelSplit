//
//  CurrencyRateFetcher.m
//  splitter
//
//  Created by Direwolf on 2012-01-12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import "CurrencyRateFetcher.h"
#import "GlobalCurrency.h"

#define CURRENCYRATES_KEY @"currencyRates"
#define LASTUPDATE_KEY @"currencyLastUpdate"

@implementation CurrencyRateFetcher

@synthesize lastUpdate, error;

-(id)init{
    
    self = [ super init ];
    
	if(self){
		NSUserDefaults* def = [ NSUserDefaults standardUserDefaults ];
		
		dict = [ NSMutableDictionary dictionaryWithCapacity:20 ];
		NSDictionary* tempDict = 
			[ def dictionaryForKey:CURRENCYRATES_KEY ];
        
		lastUpdate = [ def objectForKey:LASTUPDATE_KEY ];
        
        //TODO: Check if cached rates are very old
		
		if( ! tempDict ){	
			NSLog(@"No cached currency rates found. Loading default..");
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"defaultCurrencies" ofType:@"xml"];  
            NSData *myData = [NSData dataWithContentsOfFile:filePath];
            
            NSXMLParser* parser = [ [ NSXMLParser alloc ] initWithData:myData ];
            parser.delegate = self;
            [ parser parse ];
            [ parser release ];
            

            NSDate *date = [NSDate dateWithTimeIntervalSince1970:283036180]; //TODO: Check that this works correctly
            //NSLog(@"%d", [[NSDate date] timeIntervalSince1970]);
            lastUpdate = date;
            
		}
		else{
			NSLog(@"Loading cached currency rates..");
            
            [ dict setDictionary:tempDict ];
		}
		
		
		[ dict retain ];
		[ lastUpdate retain ];
	}
	return self;
}

-(void)dealloc {
	[ lastUpdate release ];
	[ dict release ];
	[ super dealloc ];
}

-(NSDictionary*) getOldRates{     //LOCAL METHOD

    
	if( [ self needsToFetch ] ){
		NSLog(@"Returning nil instead of dict because we need to fetch currency rates!");
		return nil;
	}
	return dict;
}

-(NSDictionary*) getCurrentRates{    //LOCAL METHOD

    
	NSURL* url = [ NSURL URLWithString:@"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml" ];
	NSXMLParser* parser = [ [ NSXMLParser alloc ] initWithContentsOfURL:url ];
    
    //TODO: Stop if no internet connection
    
	parser.delegate = self;
	[ parser parse ];
	[ parser release ];
	lastUpdate = [ NSDate date ];
	if( error ){
		return nil;
	}
    
    
    NSUserDefaults* def = [ NSUserDefaults standardUserDefaults ];
	[ def setObject:dict forKey:CURRENCYRATES_KEY ];
	[ def setObject:lastUpdate forKey:LASTUPDATE_KEY ];
	[ def synchronize ];
    
	return dict;
}

-(bool) needsToFetch{
	return [ dict count ] == 0;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if( error )
		return;
	if( [elementName isEqualToString:@"Cube"] ){
		NSString* currency = [ attributeDict objectForKey:@"currency" ];
		if( currency ){
			NSString* rate = [ attributeDict objectForKey:@"rate" ];
			float floatVal = [ rate floatValue ];
			if( !floatVal ){
				NSLog(@"ERROR: invalid currency rate for %@", currency );
				error = TRUE;
				return;
			}
			NSNumber* numRate = [ NSNumber numberWithFloat:floatVal];
			[ dict setObject:numRate forKey:currency ];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	//
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//
}

-(Money*) money:(float)amount currency:(NSString*)cur {
	if( error ) {
		NSLog(@"An error has occurred. Will not create more money-objects because currency rates are probably invalid");
		return nil;
	}
	NSNumber* val = [ dict objectForKey:cur ];
    
    if([cur isEqualToString:@"EUR"]) {
        val = [NSNumber numberWithInt:1];
    }
    
	if( val ) {
		return [ Money moneyWithAmount:amount relativeCurrency:[val floatValue ] andCurrency:cur ];
	}
	return nil;
}

-(BOOL) containsCurrency:(NSString*)currency {
    if([currency isEqualToString:@"EUR"]) {
        return YES;
    }
    
	NSNumber* val = [ dict objectForKey:currency ];
	if( val ) {
		return YES;
	}
	return NO;
}

-(NSNumber*)getRateFor:(NSString*)currency {
    
    NSNumber* val = [ dict objectForKey:currency ];
    
    if([currency isEqualToString:@"EUR"]) {
        val = [NSNumber numberWithInt:1];
    }
    
    return val;
    
}

-(Money*)emptyMoney {
    return [self money:0 currency:[GlobalCurrency get]];
}

@end
