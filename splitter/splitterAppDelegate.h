//
//  splitterAppDelegate.h
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BillListViewController.h"

@interface splitterAppDelegate : NSObject <UIApplicationDelegate> {

    UITabBarController *tabBarController;
    BillListViewController *billList;
    UIViewController *balance;
    
    CurrencyRateFetcher *fetcher;
    
        
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
