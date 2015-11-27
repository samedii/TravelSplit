//
//  BillListViewController.h
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BillBook.h"
#import "Group.h"
#import "DetailedBillViewController.h"
#import "IconPickerViewController.h"
#import "PayerPickerViewController.h"
#import "ParticipantsPickerViewController.h"


@interface BillListViewController : UIViewController<ParticipantPickerListener,DetailedBillViewListener> {
    
    BillBook *billBook;
    Group    *group;
    
    UINavigationController    *navController;
    
    IconPickerViewController  *iconPicker;
    PayerPickerViewController *payerPicker;
    ParticipantsPickerViewController *participantPicker;
    
    CurrencyRateFetcher* fetcher;
    
}

//@property (retain) UINavigationController *navController;

- (id)initWithBillBook:(BillBook*)aBillBook currencies:(CurrencyRateFetcher*)aFetcher andGroup:(Group*)aGroup;

-(void)clickedBill:(Bill*)bill;


//Local
-(UIView*)createNewBillList;

@end
