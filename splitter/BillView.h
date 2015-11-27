//
//  BillView.h
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Bill.h"
#import "BillListViewController.h"

@interface BillView : UIView {
    
    BOOL isGreen;
    id listener;
	Bill* bill;
}

- (id)initWithFrame:(CGRect)frame listener:(id)aListener andBill:(Bill*)aBill;

@end
