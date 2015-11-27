//
//  TransactionViewController.h
//  splitter
//
//  Created by Direwolf on 2011-12-21.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TransactionViewController : UIViewController {
    
	IBOutlet UILabel *from, *to;
	IBOutlet UILabel *amount;
    IBOutlet UILabel *fromLast, *toLast;
    
}

@property (retain) UILabel *from, *to, *amount,*fromLast,*toLast;

@end
