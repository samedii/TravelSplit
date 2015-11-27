//
//  NSStringFormatting.m
//  splitter
//
//  Created by Richard Hermanson on 20/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "NSStringFormatting.h"


@implementation NSString (NSStringFormatting)

+(NSString*)formattedStringFromNumber:(NSNumber*)number {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[ formatter setMinimumFractionDigits:0];
	[ formatter setMaximumFractionDigits:1 ];
    NSString *convertNumber = [formatter stringForObjectValue:number];

    [formatter release];
    
    return convertNumber;
    
}

@end
