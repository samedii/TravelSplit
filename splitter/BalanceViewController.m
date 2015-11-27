//
//  BalanceViewController.m
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "BalanceViewController.h"

#import "Bill.h"

#import "NSStringFormatting.h"

#import "Money.h"
#import "GlobalCurrency.h"

@implementation BalanceViewController

- (id)initWithBillBook:(BillBook*)aBillBook andCurrencies:(CurrencyRateFetcher *)aFetcher
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        
        splitter = nil;
        
        currencyField = nil;
        
        fetcher = aFetcher;
        
        billBook = aBillBook;
        balance2 = [self calculateBalance];
        [balance2 retain];
        

		
		UIImage* img = [ UIImage imageNamed: @"scale.png" ];
		self.tabBarItem = [ [ [ UITabBarItem alloc ] initWithTitle:@"Balance" image:img tag:2 ] autorelease ];
    }
    return self;
}

- (void)dealloc
{
    [balance2 release];
    [currencyButton release];
    [currencyField release];
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
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UIView *aView = [[UIView alloc] initWithFrame:frame];
    //[aView setBackgroundColor:[UIColor blueColor]];
    
    //table
    CGRect tableFrame = CGRectMake(0, 20, 320, 374); //412
    table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    [table setBounces:NO];
    [table setUserInteractionEnabled:YES];
    [table setDataSource:self];
    
    [aView addSubview:table];
    [table release];
    
    //split button
    CGRect splitFrame = CGRectMake(85, 380, 150, 24);
    UIButton *splitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [splitButton setFrame:splitFrame];
    [splitButton setTitle:@"Settle bills" forState:UIControlStateNormal];
    [splitButton addTarget:self action:@selector(settleClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [aView addSubview:splitButton];
    
    //currency button
    
    CGRect curFrame = CGRectMake(245, 380, 60, 24);
    currencyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [currencyButton retain];
    [currencyButton setFrame:curFrame];
    [currencyButton setTitle:[GlobalCurrency get] forState:UIControlStateNormal];
    [currencyButton addTarget:self action:@selector(changeCurrencyClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [aView addSubview:currencyButton];
    
    
    [self setView:aView];
    [aView release];

}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"Balance count: %i, self count: %i", [balance2 retainCount], [self retainCount]);
    
    [balance2 release];
    NSLog(@"TODO: fix bad access");
    if(self == nil) {
        NSLog(@"Why is self nil? balanceVC");
    }
    balance2 = [self calculateBalance]; //TODO: EXC_BAD_ACCESS
    [balance2 retain];
    
    [currencyButton setTitle:[GlobalCurrency get] forState:UIControlStateNormal];
    
    //[splitter updateBalance:balance2];
    
    [table reloadData];
    
    [splitter release];
    splitter = [[SplitterViewController alloc] initWithBalance:balance2 currencies:fetcher andListener:self];
    
    [super viewWillAppear:animated];
}

-(NSDictionary*)calculateBalance {
    
    NSMutableDictionary *balance = [[NSMutableDictionary alloc] init];
    
    NSArray *billList = [billBook getBillList];
    
    NSEnumerator *e = [billList objectEnumerator];

    Bill *b;
    
    while((b = [e nextObject])) {
        
        NSDictionary *buyers = [b buyers];
        
        NSEnumerator *e2 = [buyers keyEnumerator];
        NSString *name;
        while((name = [e2 nextObject])) {
            if([balance objectForKey:name]) {
                
                Money *amount = [balance objectForKey:name];
                amount = [amount sumWith:[buyers objectForKey:name]];
                
                //float amount = [[balance objectForKey:name] trueValue];

                //amount += [[buyers objectForKey:name] trueValue];
                
                [balance setObject:amount forKey:name];
            }
            else {
                Money *amount = [fetcher money:0 currency:[GlobalCurrency get]];
                
                if([buyers objectForKey:name] == nil) {
                    NSLog(@"Error: Should have paid");
                }
                
                if(![[buyers objectForKey:name] isMemberOfClass:[Money class]]) {
                    NSLog(@"Error: Buyers contains something else than money (probably numbers)");
                    
                    //[buyers setValue:[fetcher money:[[buyers objectForKey:name] floatValue] currency:[GlobalCurrency get]] forKey:name];
                }
                
                amount = [amount sumWith:[buyers objectForKey:name]];
                [balance setObject:amount forKey:name];
            }
        }
        
        NSDictionary *participants = [b participants];
        
        
        Money *total = [fetcher money:[[b amount] trueValue] currency:@"EUR"];
        e2 = [participants objectEnumerator];
        Money *mon;
        while((mon = [e2 nextObject])) {
            total = [total subtract:mon];
        }
        
        e2 = [participants keyEnumerator];
        while((name = [e2 nextObject])) {
            if([balance objectForKey:name]) {
                //float amount = [[balance objectForKey:name] trueValue];
                //amount -= [[b amount] trueValue]/(float)[participants count]; //antar att alla deltagare tar lika skuld
                Money *amount = [balance objectForKey:name];
                Money *s = [fetcher money:[total trueValue]/(float)[participants count] currency:@"EUR"];
                amount = [amount subtract:s];
                amount = [amount subtract:[participants objectForKey:name]];
                
                [balance setObject:amount forKey:name];
            }
            else {
                //[balance setObject:[NSNumber numberWithFloat:-[[b amount] trueValue]/(float)[participants count]] forKey:name];
                Money *amount = [fetcher money:0 currency:[GlobalCurrency get]];
                Money *s = [fetcher money:[total trueValue]/(float)[participants count] currency:@"EUR"];
                amount = [amount subtract:s];
                amount = [amount subtract:[participants objectForKey:name]];
                
                [balance setObject:amount forKey:name];
            }
        }
        
        
    }
    
    NSDictionary *tmp = [NSDictionary dictionaryWithDictionary:balance];
    [balance release];
    return tmp;
    
}

-(void)settleClicked {
    
    [self presentModalViewController:splitter animated:YES];
    
}

-(void)closeDialog {
	//TODO this is actually in violation of apple programming guidelines.
	//dissmissal should take place in a delegate or in the dialog itself
    NSLog(@"Warning: Deprecated method");
	[self dismissModalViewControllerAnimated:TRUE ];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [balance2 release];
    balance2 = [self calculateBalance];
    [balance2 retain];
    
    [super viewDidLoad];
}
*/

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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[balance2 allKeys] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect cellFrame = CGRectMake(0, 0, 320, 44);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:cellFrame];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //Name
    CGRect nameFrame = CGRectMake(6, 0, 218, 44);
    UILabel *name = [[UILabel alloc] initWithFrame:nameFrame];
    NSString *key = [[balance2 allKeys] objectAtIndex:indexPath.row];
    [name setText:key];
    //[name setBackgroundColor:[UIColor redColor]];
    [cell addSubview:name];
    
    //Balance
    CGRect balanceFrame = CGRectMake(230, 0, 90, 44);
    UILabel *balance = [[UILabel alloc] initWithFrame:balanceFrame];
    Money *number = [balance2 objectForKey:key];
    [balance setTextAlignment:UITextAlignmentRight];
    //[balance setText:[NSString formattedStringFromNumber:number]];
    //[balance setText:[number stringValue]];
    [balance setText:[ NSString stringWithFormat: @"%i\t\t", [number intValue] ]];
    if([number floatValue] < 0) {
        [balance setTextColor:[UIColor redColor]];
    }
    else {
        [balance setText:[NSString stringWithFormat:@" %@", balance.text]];
    }
    //[balance setBackgroundColor:[UIColor greenColor]];
    [cell addSubview:balance];
    [name release];
    [balance release];
    return [cell autorelease];
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Name                                  Balance";
}

-(void)changeCurrencyClicked {
    
    UIAlertView *inputCurrencyAlert = [[UIAlertView alloc] initWithTitle:@"Change currency"
                                                         message:@""
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Ok", nil];
    inputCurrencyAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [currencyField release];
    currencyField = [inputCurrencyAlert textFieldAtIndex:0];
    [currencyField retain];
    currencyField.keyboardType=UIKeyboardTypeAlphabet;
    
    [inputCurrencyAlert show];
    [inputCurrencyAlert release];
    /*
    UIAlertView *inputCurrencyAlert = [[UIAlertView alloc] initWithTitle:@"Change currency" message:@"\n\n\n" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    UILabel *curLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
    curLabel.font = [UIFont systemFontOfSize:16];
    curLabel.textColor = [UIColor whiteColor];
    curLabel.backgroundColor = [UIColor clearColor];
    curLabel.shadowColor = [UIColor blackColor];
    curLabel.shadowOffset = CGSizeMake(0,-1);
    curLabel.textAlignment = UITextAlignmentCenter;
    curLabel.text = @"Currency";
    [inputCurrencyAlert addSubview:curLabel];
    
    UIImageView *alertImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"passwordfield" ofType:@"png"]]];
    alertImage.frame = CGRectMake(11,79,262,31);
    [inputCurrencyAlert addSubview:alertImage];
    
    [currencyField release];
    currencyField = [[UITextField alloc] initWithFrame:CGRectMake(16,83,252,25)];
    currencyField.font = [UIFont systemFontOfSize:18];
    currencyField.backgroundColor = [UIColor whiteColor];
    currencyField.secureTextEntry = NO;
    currencyField.keyboardAppearance = UIKeyboardAppearanceAlert;
    currencyField.delegate = self;
    [currencyField becomeFirstResponder];
    [inputCurrencyAlert addSubview:currencyField];
    
    
    [inputCurrencyAlert show];
    [inputCurrencyAlert release];
    [alertImage release];
    [curLabel release];
     */
    
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1) {
        //save new user
        NSString *cur = [currencyField text];
            cur = [cur uppercaseString];
        if([fetcher containsCurrency:cur]) {
            
            [currencyButton setTitle:cur forState:UIControlStateNormal];
            
            [GlobalCurrency set:cur];
            
            [balance2 release];
            balance2 = [self calculateBalance];
            [balance2 retain];
            
            [table reloadData];

        }
        else {
            
            NSString *message = [NSString stringWithFormat:@"Couldn't find currency %@", [currencyField text]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
        }
        

    }
}

@end
