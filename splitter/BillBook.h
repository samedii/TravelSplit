//
//  BillBook.h
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Bill.h"

@interface BillBook : NSObject {
    
    NSArray *bills;
    
    NSLock *saveLock;
    
}

-(NSArray*)getBillList;
-(void)addBill:(Bill*)aBill;
-(void)changeBill:(Bill*)oldBill to:(Bill*)newBill;
-(void)deleteBill:(Bill*)aBill;

-(void)clearBills;

//Local

-(void)_saveBills:(NSArray*)someBills;
-(void)_encodeAndSave:(NSArray*)someBills;

@end
