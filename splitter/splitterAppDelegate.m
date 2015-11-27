//
//  splitterAppDelegate.m
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "splitterAppDelegate.h"

#import "BillListViewController.h"
#import "BillBook.h"
#import "BalanceViewController.h"
#import "Group.h"

#import "GlobalCurrency.h"
#import "CurrencyRateFetcher.h"

//temp imports
#import "Bill.h"
#import "BillView.h"

@implementation splitterAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     [UIApplication sharedApplication].statusBarHidden = YES;
    
    
    [GlobalCurrency setup];
    NSLog(@"Global currency is %@", [GlobalCurrency get]);
    
    fetcher = [ [ CurrencyRateFetcher alloc ] init ];
    
    BillBook *billBook = [[BillBook alloc] init];
    Group *group = [[Group alloc] init];
    
    tabBarController = [[UITabBarController alloc] init];
    
    
    
    billList = [[BillListViewController alloc] initWithBillBook:billBook currencies:fetcher andGroup:group];
    //UINavigationController *billNavController = [[UINavigationController alloc] initWithRootViewController:billList];
    //billList.navController = billNavController;
    //billList.navigationController = billNavController;

    
    balance = [[BalanceViewController alloc] initWithBillBook:billBook andCurrencies:fetcher];
    
    NSArray *controllers = [NSArray arrayWithObjects:billList, balance, nil];
    
    [tabBarController setViewControllers:controllers];
    
    self.window.rootViewController = tabBarController;

    [group release];
    [billBook release];
     
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [fetcher release];
    [billList release];
    [balance release];
    [tabBarController release];
    [_window release];
    [super dealloc];
}

@end
