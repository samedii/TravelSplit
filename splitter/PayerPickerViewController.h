//
//  PayerPickerViewController.h
//  splitter
//
//  Created by Richard Hermanson on 25/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>

#import <AddressBookUI/AddressBookUI.h>
#import "Group.h"
#import "InputProxy.h"

#import "CurrencyRateFetcher.h"

@protocol PayerPickerViewProtocol <NSObject>

-(BOOL)canDeleteUser:(NSString*)user;

-(void)payersPicked;

@end

@interface PayerPickerViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, InputProxyListener> {
    
    id<PayerPickerViewProtocol> listener;
    Group *group;
    
    UITableView *paid;
    
    NSMutableDictionary *payers;
    
    NSMutableArray *groupArray;
    
    NSMutableArray *inputProxies;
    NSMutableArray *currencyProxies;
    
    UITextField *nameField;//For new user
    UITextField *currencyField;//For changing currency
    
    CurrencyRateFetcher *currencies;

}

@property (readonly) NSDictionary *payers;

- (id)initWithListener:(id)aListener currencies:(CurrencyRateFetcher*)currencies2 andGroup:(Group*)aGroup;

-(void)updatePayers;

@end
