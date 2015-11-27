//
//  GlobalCurrency.h
//  splitter
//
//  Created by Richard Hermanson on 29/01/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GlobalCurrency : NSObject {

}

+(void)setup;

+(void)set:(NSString*)aCurrency;
+(NSString*)get;

@end
