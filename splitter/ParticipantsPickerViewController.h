//
//  ParticipantsPickerViewController.h
//  splitter
//
//  Created by Richard Hermanson on 19/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>

#import <AddressBookUI/AddressBookUI.h>
#import "Group.h"
#import "CurrencyRateFetcher.h"
#import "SpecialProxy.h"
#import "InputProxy.h"
#import "CurrencyProxy.h"

@protocol ParticipantPickerListener <NSObject>

- (void)participantsPicked;

-(BOOL)canDeleteUser:(NSString*)user;

@end


@interface ParticipantsPickerViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, SpecialProxyListener, CurrencyProxyListener, InputProxyListener> {
    
    id<ParticipantPickerListener> listener;
    Group *group;
    
    UITableView *table;
    
    NSMutableDictionary *participants; //<- changed to dict
    
    NSMutableArray *groupArray;
    
    UITextField *nameField;//For new user
    
    NSMutableDictionary *specialProxies;
    
    NSMutableArray *inputProxies;
    NSMutableArray *currencyProxies;
    
    CurrencyRateFetcher *currencies;
    
}

@property (readonly) NSMutableDictionary *participants;

- (id)initWithListener:(id)aListener currencies:(CurrencyRateFetcher*)curr andGroup:(Group*)aGroup;

-(void)updateParticipants;

-(NSMutableDictionary*)_newDictionaryFromGroup;

@end
