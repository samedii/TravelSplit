//
//  BillBook.m
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "BillBook.h"

@implementation BillBook

-(id)init
{
    self = [super init];
    if(self)
    {
        saveLock = [[NSLock alloc] init];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        //bills = [prefs arrayForKey:@"bills"]; //returns nil if no array found
        
        NSData *encodedBills = [prefs objectForKey:@"bills"];
        bills = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:encodedBills];
        
        [bills retain];
    }
    
    return self;
}


-(NSArray*)getBillList
{
    return [NSArray arrayWithArray:bills];   //may want to return an ordered list (or save ordered)
}


-(void)addBill:(Bill*)aBill
{
    NSArray *newBills;
    if(bills)
    {
        newBills = [bills arrayByAddingObject:aBill];
        [bills release];
    }
    else
        newBills = [NSArray arrayWithObject:aBill];
    
    bills = newBills;
    [bills retain];
    
    [self _saveBills:bills];
}


-(void)changeBill:(Bill*)oldBill to:(Bill*)newBill
{
    if([bills containsObject:oldBill])
    {
        //change bills
        NSMutableArray *mutable = [NSMutableArray arrayWithArray:bills];
        
        int index = [mutable indexOfObject:oldBill];
        [mutable replaceObjectAtIndex:index withObject:newBill];
        
        //save
        NSArray *newBills = [NSArray arrayWithArray:mutable];
        [bills release];
        
        bills = newBills;
        [bills retain];
        
        //[self performSelectorInBackground:@selector(_saveBills:) withObject:bills];
        [self _saveBills:bills];
        
    }
    else
    {
        NSLog(@"Error: Change bill failed because old bill not found");
        return;
    }
    
    return;
}


-(void)_saveBills:(NSArray*)someBills
{

    [self performSelectorInBackground:@selector(_encodeAndSave:) withObject:someBills];

}

-(void)_encodeAndSave:(NSArray*)someBills {
    
    [saveLock lock];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedBills = [NSKeyedArchiver archivedDataWithRootObject:someBills];
    
    [prefs setObject:encodedBills forKey:@"bills"];
    
    [prefs synchronize];
    
    [saveLock unlock];
    
}

-(void)dealloc {
    [bills release];
    [super dealloc];
}

-(void) deleteBill:(Bill *)aBill{

    NSMutableArray *newBills = [[NSMutableArray alloc] initWithArray:bills];
    [newBills removeObject:aBill];
    
    [bills release];
    bills = newBills;
    [bills retain];
    
    [self _saveBills:bills];
    
}

-(void)clearBills {
    
    [bills release];
    bills = [NSArray arrayWithObjects:nil];
    [bills retain];
    
    [self _saveBills:[NSArray arrayWithObjects:nil]];
    
}


@end
