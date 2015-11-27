//
//  SplitterViewController.h
//  splitter
//
//  Created by Richard Hermanson on 21/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CurrencyRateFetcher.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h> 
#import <MessageUI/MFMessageComposeViewController.h>


@protocol DialogCloser

-(void) closeDialog;

@end


@interface SplitterViewController : UIViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    NSDictionary *balance;
    id <DialogCloser> listener;
    
    NSArray *Negative, *Positive;
    
    NSMutableArray *solution;
    CurrencyRateFetcher *fetcher;
    
    NSMutableArray *transactions;
    
}

- (id)initWithBalance:(NSDictionary*)aBalance currencies:(CurrencyRateFetcher*)aFetcher andListener:(id<DialogCloser>)listener;
-(void)updateBalance:(NSDictionary*)aBalance;

-(void)calculateOrderedBalances;
-(void) calculateTransactions;

-(void)launchMailAppOnDevice;
-(void)displayComposerSheet;
-(void)displaySmsComposerSheet;

+(NSArray*)compareNumber:(float)num to:(NSArray*)numbers;

-(NSArray*)_namesFromSolution;
-(NSArray*)_finalNameSolution;

@end
