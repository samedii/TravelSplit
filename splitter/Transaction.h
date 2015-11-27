//
//  Transaction.h
//  splitter
//
//  Created by Richard Hermanson on 06/02/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Money.h"

@interface Transaction : NSObject {
    NSString *from;
    float amount;
    NSString *to;
}

@property (retain) NSString *from, *to;
@property (assign) float amount;

@end
