//
//  BalanceViewController.h
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BillBook.h"

#import "SplitterViewController.h"

#import "CurrencyRateFetcher.h"

@interface BalanceViewController : UIViewController <UITableViewDataSource, DialogCloser,UITextFieldDelegate> {
    BillBook *billBook;
    NSDictionary *balance2;
    UITableView *table;
    SplitterViewController *splitter;
    CurrencyRateFetcher *fetcher;
    
    UIButton *currencyButton;
    UITextField *currencyField;
}

- (id)initWithBillBook:(BillBook*)aBillBook andCurrencies:(CurrencyRateFetcher*)aFetcher;



-(NSDictionary*)calculateBalance;

@end
