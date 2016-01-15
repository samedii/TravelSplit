//
//  BillListViewController.m
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "BillListViewController.h"
#import "DetailedBillViewController.h"
#import "Bill.h"
#import "BillView.h"
#import "CurrencyRateFetcher.h"
#import "GlobalCurrency.h"

#import "Money.h"

@implementation BillListViewController

- (id)initWithBillBook:(BillBook*)aBillBook currencies:(CurrencyRateFetcher*)aFetcher andGroup:(Group *)aGroup
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        
        [aBillBook retain];
        billBook = aBillBook;
        [aGroup retain];
        group = aGroup;
        
        fetcher = aFetcher;
        
		self.title      = @"Bills";
		UIImage* img    = [ UIImage imageNamed:@"bills.png" ];
		self.tabBarItem = [ [ [ UITabBarItem alloc ] initWithTitle:@"Bills" image:img tag:0 ] autorelease ];
		

        
    }
    return self;
}

- (void)dealloc
{
    [payerPicker release];
    [participantPicker release];
    [billBook release];
    [group release];
    [iconPicker release];
    [navController release];
    [billList release];
    [addButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
     [UIApplication sharedApplication].statusBarHidden = YES;
    
    iconPicker = [[IconPickerViewController alloc] initWithListener:self];
    
    navController = [[UINavigationController alloc] initWithRootViewController:iconPicker];
    

    payerPicker = [[PayerPickerViewController alloc] initWithListener:self currencies:fetcher andGroup:group];
    
    participantPicker = [[ParticipantsPickerViewController alloc] initWithListener:self currencies:fetcher andGroup:group];
    
    
    
    /*
    NSDate *aDate = [NSDate date];
    NSDictionary *someBuyers = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:210],@"Richard Hermanson", nil];
    NSArray *someParticipants = [NSArray arrayWithObjects:@"Richard Hermanson", @"Erik Peldan", @"Nils Pedersen", nil];
    Money *m = [Money moneyWithAmount:100 relativeCurrency:10 andCurrency:@"SEK"];
    NSString *anImage = @"food.png";
    NSString *aTitle = @"Badminton";
    
    Bill *aBill = [[Bill alloc] initWithDate:aDate isYours:NO buyers:someBuyers participants:someParticipants amount:m icon:anImage andTitle:aTitle];
    
    Bill *anotherBill = [[Bill alloc] initWithDate:aDate isYours:YES buyers:someBuyers participants:someParticipants amount:m icon:anImage andTitle:aTitle];
    */
    //[billBook addBill:aBill];
    //[billBook addBill:anotherBill];
    /*
    NSArray *test = [billBook getBillList];
    for (Bill *b in test) {
        NSLog([NSString stringWithFormat:@"%i", b.amount]);
    }
    
    CGRect billRect = CGRectMake(0, 10, 320, 200);
    BillView *billView = [[BillView alloc] initWithFrame:billRect andBill:aBill];
    
    billRect = CGRectMake(0, billView.frame.size.height+16, 320, 400);
    BillView *anotherBillView = [[BillView alloc] initWithFrame:billRect andBill:anotherBill];
    
    [billListView addSubview:billView];
    [billListView addSubview:anotherBillView];
    
    */
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    UIView *box = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-20-49)];
    billList = [self createNewBillList];
    [box addSubview:billList];
    [self setView:box];
    
    
    //[billListView release];
    
    
    
    //Creating view controller for adding new bills
    
    //iconPicker = [[IconPickerViewController alloc] init];
    //navBarController = [[UINavigationController alloc] initWithRootViewController:self];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [billList scrollRectToVisible:addButton.frame animated:NO];
}

-(void)removeAllBills {
	UIAlertView* alert = [ [ UIAlertView alloc ] initWithTitle:@"Are you sure?" message:@"This will delete all your bills.\n" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes!",nil ];
	[ alert show ];
	[ alert release ];
}

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {
    if(buttonIndex == 1) {
		//This means OK

		[ billBook clearBills ];
		self.view = [ self createNewBillList ];
        
        [group removeAllUsers];
        
	}
} 

-(UIScrollView*)createNewBillList {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect scrollFrame = CGRectMake(0, 20, screenWidth, screenHeight-20-49);
    UIScrollView *billListView = [[UIScrollView alloc] initWithFrame:scrollFrame];

    //for bill in billList create bill and add to scroll view
    
    NSArray *billList = [billBook getBillList];
    [billList retain];
    
	
	int posY = 10;
	if( [ billList count ] ){
		
		UIButton* trash = [ UIButton buttonWithType:UIButtonTypeCustom ];
		UIImage* trashImg = [ UIImage imageNamed:@"trash.png" ];
		[ trash setImage:trashImg forState:UIControlStateNormal ];
		//[ trash setTitle:@"Trash" forState:UIControlStateNormal ];
		[billListView addSubview:trash ];
		CGRect rt = trash.frame;
		rt.origin = CGPointMake(320 - 60, 2);
		rt.size = CGSizeMake(60,50);
		trash.frame = rt;
		[trash addTarget:self action:@selector(removeAllBills) forControlEvents:UIControlEventTouchUpInside];
		
		posY += 44;
	}
    
    
    for (Bill *aBill in billList) {
        CGRect aFrame = CGRectMake(0, posY, 320, 200);
        BillView *aBillView = [[BillView alloc] initWithFrame:aFrame listener:self andBill:aBill];
        [billListView addSubview:aBillView];
        
        posY += aBillView.frame.size.height + 6;
        [aBillView release];
    }
    
    [billList release];
    
    //add button
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];//[UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *addButtonImg = [UIImage imageNamed:@"cleaned-plus.png"];
    [addButton setImage:addButtonImg forState:UIControlStateNormal];
    
    int imageSize = 45;
    [addButton setFrame:CGRectMake(320-9-imageSize, posY, imageSize, imageSize)];
    posY += imageSize + 10;
    //[addButton setTitle:@"Add bill" forState:UIControlStateNormal];
    
    [addButton addTarget:self action:@selector(startCreateBill) forControlEvents:UIControlEventTouchUpInside];
    
    [billListView addSubview:addButton];
    
    [billListView setContentSize:CGSizeMake(320, posY)];
    [billListView scrollRectToVisible:addButton.frame animated:NO];
    
    

    
    return [billListView autorelease];
    
}




-(void)startCreateBill {
    
    [self presentModalViewController:navController animated:YES];
    
}

-(void)iconPicked {
    [navController pushViewController:payerPicker animated:YES];
}

-(void)payersPicked {
    [navController pushViewController:participantPicker animated:YES];
}

-(void)participantsPicked {
    
    //create bill
    
    
    NSDictionary *buyers = [payerPicker payers];
    NSDictionary *participants = [participantPicker participants];
    
    Money *amount = [fetcher money:0 currency:[GlobalCurrency get]];
    
    NSEnumerator *en = [buyers keyEnumerator];
    NSString *name;
    //float amount = 0;
    while((name = [en nextObject])) {
        //amount += [[buyers objectForKey:name] trueValue];
        Money *m = [buyers objectForKey:name];
        amount = [amount sumWith:m];
        
    }
    
    NSString *iconName = [iconPicker pickedIcon];
    NSString *title = [iconPicker pickedIconLabel];
    
    NSDate *date = [NSDate date];
    
    Bill *b = [[Bill alloc] initWithDate:date isYours:YES buyers:buyers participants:participants amount:amount icon:iconName andTitle:title];
    
    [billBook addBill:b];
    
    //self eller nav?
    //[navController popToRootViewControllerAnimated:NO];
    [navController dismissModalViewControllerAnimated:YES];
    
    
    //clean up
    [iconPicker release];
    [navController release];
    [payerPicker release];
    [participantPicker release];
    
    iconPicker = [[IconPickerViewController alloc] initWithListener:self];
    
    navController = [[UINavigationController alloc] initWithRootViewController:iconPicker];
    
    payerPicker = [[PayerPickerViewController alloc] initWithListener:self currencies:fetcher andGroup:group];
    
    participantPicker = [[ParticipantsPickerViewController alloc] initWithListener:self currencies:fetcher andGroup:group];
    
    //refresh
    [b release];
    
    [self setView:[self createNewBillList]];
}

-(void)clickedBill: (Bill*)bill {
	DetailedBillViewController *detailed = [ [ DetailedBillViewController alloc ] initWithBill:bill andListener:self ];
    if(detailed == nil) {
        NSLog(@"Error: Failed to create detailed bill view.");
        return;
    }
	[ self presentModalViewController:detailed animated:TRUE ];
    [detailed release];
}

-(void)removeBill:(Bill*)bill {
    [billBook deleteBill:bill];
    [self setView:[self createNewBillList]];
}


-(void)addDesc:(Bill*)bill desc:(NSString*)desc{
    NSLog(@"Warning: Use of deprecated method");
}

-(Bill*)newDesc:(NSString*)desc toBill:(Bill*)aBill {
    Bill *newBill = [aBill billWithNewDescription:desc];
    
    [billBook changeBill:aBill to:newBill];
    
    //Update bill list.
    [self setView:[self createNewBillList]];
    
    [newBill retain];
    
    return newBill;
}

-(Bill*)newTitle:(NSString*)title toBill:(Bill*)aBill {
    Bill *newBill = [aBill billWithNewTitle:title];
    
    [billBook changeBill:aBill to:newBill];
    
    //Update bill list.
    [self setView:[self createNewBillList]];
    [newBill retain];
    return newBill;
}

-(Bill*)newImage:(UIImage*)image toBill:(Bill*)aBill {
    Bill *newBill = [aBill billWithNewImage:image];
    
    [billBook changeBill:aBill to:newBill];
    
    //Update bill list.
    [self setView:[self createNewBillList]];
    
    [newBill retain];
    
    return newBill;
}

-(BOOL)canDeleteUser:(NSString*)user {
    
    NSArray *bills = [billBook getBillList];
    
    for(Bill *bill in bills) {
        
        NSString *aUser;
        for(aUser in bill.participants) {
            if([aUser isEqualToString:user]) {
                return NO;
            }
        }
        
        for(aUser in bill.buyers) {
            if([aUser isEqualToString:user]) {
                return NO;
            }
        }
        
    }
    
    return YES;
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
