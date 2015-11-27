//
//  PayerPickerViewController.m
//  splitter
//
//  Created by Richard Hermanson on 25/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "PayerPickerViewController.h"

#import "NSStringFormatting.h"

#import "Money.h"

#import "CurrencyProxy.h"

#import "GlobalCurrency.h"

@implementation PayerPickerViewController

@synthesize payers;

- (id)initWithListener:(id)aListener currencies:(CurrencyRateFetcher*)currencies2 andGroup:(Group *)aGroup
{
    self = [super init];
    if (self) {
        // Custom initialization
        listener = aListener;
        payers = [[NSMutableDictionary alloc] init];
        group = aGroup;
        groupArray = [[NSMutableArray alloc] initWithArray:[group getUsers]];
        
        inputProxies = [[NSMutableArray alloc] initWithCapacity:[groupArray count]];
        currencyProxies = [[NSMutableArray alloc] initWithCapacity:[groupArray count]];
        
        NSEnumerator *e = [groupArray objectEnumerator];
        NSString *name;
        while((name = [e nextObject])) {
            InputProxy *proxy = [[InputProxy alloc] initWithUser:name andTarget:self];
            [inputProxies addObject:proxy];
            [proxy release];
        }
        
        e = [groupArray objectEnumerator];
        while((name = [e nextObject])) {
            CurrencyProxy *proxy = [[CurrencyProxy alloc] initWithUser:name andTarget:self];
            [currencyProxies addObject:proxy];
            [proxy release];
        }
        
        
        
        currencies = currencies2;
        
        nameField = nil;
        currencyField = nil;
        
        
    }
    return self;
}

- (void)dealloc
{
    [payers release];
    [paid release];
    [groupArray release];
    [inputProxies release];
    [currencyProxies release];
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
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [self.navigationItem setTitle:@"Who paid?"];
    
    const int TABLE_HEIGHT = 352;
    
    //Paid and participants table
    CGRect paidFrame = CGRectMake(0, 0, 320, TABLE_HEIGHT);
    paid = [[UITableView alloc] initWithFrame:paidFrame style:UITableViewStyleGrouped];
    [paid setDataSource:self];
    [paid setDelegate:self];
    [aView addSubview:paid];
    
    //Menu border
    CGRect borderFrame = CGRectMake(0, TABLE_HEIGHT, 320, 1);
    UIView *border = [[UIView alloc] initWithFrame:borderFrame];
    [border setBackgroundColor:[UIColor grayColor]];
    [aView addSubview:border];
    [border release];
    //"Add from contacts" button
    
    const int   MENU_HEIGHT = 40,
                ADD_WIDTH = 152,
                SPACING = 6;
    
    CGRect addFrame = CGRectMake(SPACING, TABLE_HEIGHT+2*SPACING, ADD_WIDTH, MENU_HEIGHT);
    UIButton *add = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [add setFrame:addFrame];

    [add setTitle:@"Add from contacts" forState:UIControlStateNormal];
    
    [add addTarget:self action:@selector(addFromContacts) forControlEvents:UIControlStateHighlighted];

    [aView addSubview:add];
    
    //"Add new" button
    const int ADD_NEW_WIDTH = 88;
    
    CGRect addNewFrame = CGRectMake(ADD_WIDTH+2*SPACING, TABLE_HEIGHT+2*SPACING, ADD_NEW_WIDTH, MENU_HEIGHT);
    UIButton *addNew = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addNew setFrame:addNewFrame];
    
    [addNew setTitle:@"Add new" forState:UIControlStateNormal];
    
    [addNew addTarget:self action:@selector(addNewUser) forControlEvents:UIControlStateHighlighted];
    
    [aView addSubview:addNew];
    
    //Continue
    const int DONE_WIDTH = 56;
    
    CGRect doneFrame = CGRectMake(ADD_WIDTH+ADD_NEW_WIDTH+3*SPACING, TABLE_HEIGHT+2*SPACING, DONE_WIDTH, MENU_HEIGHT);
    UIButton *done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [done setFrame:doneFrame];
    
    [done setTitle:@"Done" forState:UIControlStateNormal];
    
    [done addTarget:self action:@selector(payerPickerDone) forControlEvents:UIControlStateHighlighted];
    
    [aView addSubview:done];
    
    [self setView:aView];
    [aView release];
}

-(void)viewWillAppear:(BOOL)animated {
    [self updatePayers];
    
    [super viewWillAppear:animated];
}

-(void)addFromContacts {
    
    ABPeoplePickerNavigationController *picker =  [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = self;
    
    [self presentModalViewController:picker animated:YES];
    
    [picker release];

}

-(void)addNewUser {
    
    UIAlertView *inputNameAlert = [[UIAlertView alloc] initWithTitle:@"New user" message:@"Name" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];

    
    //VERSION DEPENDENT CODE
    
    //iOS 5+ only
    if ([inputNameAlert respondsToSelector:@selector(setAlertViewStyle:)]) {
        
        //inputNameAlert =  [[UIAlertView alloc] initWithTitle:@"New user" message:@"Name" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        
        [inputNameAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        //[self setAlertTextField:[alert textFieldAtIndex:0]];
        nameField = [inputNameAlert textFieldAtIndex:0];
    } else {
        
        [inputNameAlert release];
        inputNameAlert = [[UIAlertView alloc] initWithTitle:@"New user" message:@"\n\n\n" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.shadowColor = [UIColor blackColor];
        nameLabel.shadowOffset = CGSizeMake(0,-1);
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.text = @"Name";
        [inputNameAlert addSubview:nameLabel];
        
        [nameLabel release];
        
        [nameField release];
        nameField = [[UITextField alloc] initWithFrame:CGRectMake(16,83,252,25)];
        nameField.font = [UIFont systemFontOfSize:18];
        nameField.backgroundColor = [UIColor whiteColor];
        nameField.secureTextEntry = NO;
        nameField.keyboardAppearance = UIKeyboardAppearanceAlert;
        nameField.delegate = self;
        [nameField becomeFirstResponder];
        [inputNameAlert addSubview:nameField];
        
        UIImageView *alertImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"passwordfield" ofType:@"png"]]];
        alertImage.frame = CGRectMake(11,79,262,31);
        [inputNameAlert addSubview:alertImage];
        
        [alertImage release];

    }
 





    [inputNameAlert show];
    [inputNameAlert release];


    
    
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    NSString *inputText = [[alertView textFieldAtIndex:0]text];
    if ([inputText length]>1) {
        return YES;
    }
    return NO;
}

- (void) payersPicked {
	NSLog(@"WARNING: PayerPickerViewController -payersPicked but not implemented!");
}

-(void)payerPickerDone {
    
    //check amounts
    
    NSEnumerator *en = [payers keyEnumerator];
    NSString *name;
    BOOL found = NO;
    while((name = [en nextObject])) {
        
		float val = [ [payers objectForKey:name] amount ];
        if(val <= 0.0f) {
            found = YES;
            break;
        }
    }
    
    
    if (found) {
		UIAlertView* alert = [ [ UIAlertView alloc ] initWithTitle:@"Error" message:@"One or more are paying an invalid amount of money" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
		[ alert show ];
		[ alert release ];
		return;
	}
	if( [ payers count ] == 0 ) {
		UIAlertView* alert = [ [ UIAlertView alloc ] initWithTitle:@"Error" message:@"No one is paying the bill!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
		[ alert show ];
		[ alert release ];
		return;
		
	}
	[listener payersPicked];
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{

    
    [super viewDidLoad];
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


-(void)updatePayers {
    
    [groupArray release];
    groupArray = [[NSMutableArray alloc] initWithArray:[group getUsers]];
    
    NSEnumerator *e = [payers keyEnumerator];
    NSString* tmpName;
    while((tmpName = [e nextObject])) {
        if([groupArray containsObject:tmpName]) {
            [groupArray removeObject:tmpName];
        }
    }
    
    
    [paid reloadData];
    /*
    if([payers count] == 1) {
        [paid setText:[payers anyObject]];
        return;
    }
    
    
    NSMutableString *payersString = [[NSMutableString alloc] init];
    
    NSEnumerator *enumerator = [payers objectEnumerator];
    
    NSString *name;
    
    int i = 1;
    while ((name = [enumerator nextObject])) {
        
        if([payers count] == i && [payers count] != 2) {
            [payersString appendFormat:@", and %@", name];
        }
        else if([payers count] == i) {
            [payersString appendFormat:@" and %@", name];
        }
        else if(i == 1) {
            [payersString appendString:name];
        }
        else {
            [payersString appendFormat:@", %@", name];
        }
        i++;
    }
    
    [paid setText:payersString];
    [payersString release];*/
}


-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [firstName release];
    [lastName release];
    
    
    if(![[payers allKeys] containsObject:name]) {
        InputProxy *proxy = [[InputProxy alloc] initWithUser:name andTarget:self];
        [inputProxies addObject:proxy];
        [proxy release];
        
        CurrencyProxy *proxy2 = [[CurrencyProxy alloc] initWithUser:name andTarget:self];
        [currencyProxies addObject:proxy2];
        [proxy2 release];
    }
    
    Money* money = [currencies money:0 currency:[GlobalCurrency get]];
    
    if(money == nil) {
        NSLog(@"Error: Money was not created properly");
    }
    else {
        [payers setObject:money forKey:name];
    
        [group addUser:name];
        
        [self updatePayers];
        
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
     [self dismissModalViewControllerAnimated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect cellFrame = CGRectMake(0, 0, paid.frame.size.width, 44);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:cellFrame];
    
    int NAME_WIDTH = 280;
    int SHORT_NAME_WIDTH = 195;
    int AMOUNT_WIDTH = 80;
    int CURRENCY_WIDTH = 40;
    
    //Name
    CGRect nameFrame = CGRectMake(19, 0, NAME_WIDTH, 44);
    UILabel *name = [[UILabel alloc] initWithFrame:nameFrame];
    
    NSArray *tempPayers = [payers allKeys];
    if(indexPath.section == 0) {
        
        nameFrame = CGRectMake(19, 0, SHORT_NAME_WIDTH, 44);
        [name setFrame:nameFrame];
        
        NSString *payer = [tempPayers objectAtIndex:indexPath.row];
        [name setText:payer];
        
        
        //Amount
        CGRect amountFrame = CGRectMake(cellFrame.size.width-AMOUNT_WIDTH-CURRENCY_WIDTH-21-5, 9, AMOUNT_WIDTH, 26);
        UITextField *input = [[UITextField alloc] initWithFrame:amountFrame];
        [input setBorderStyle:UITextBorderStyleRoundedRect];
        //[input setBackgroundColor:[UIColor redColor]];
        [input setKeyboardType:UIKeyboardTypeDecimalPad];
        Money *number = [payers objectForKey:payer];
        if([number amount] == 0) {
            [input setText:@""];
        }
        else {
            [input setText:[NSString formattedStringFromNumber:[number getNumber]]];
        }
     
        NSEnumerator *en = [inputProxies objectEnumerator];
        InputProxy *proxy;
        BOOL found = NO;
        while((proxy = [en nextObject])) {
            if([payer isEqualToString:proxy.name]) {
                found = YES;
                break;
            }
        }
        if(!found) {
            NSLog(@"Error: Did not find a proxy for payer");
        }
        
        [input setDelegate:proxy];
		input.returnKeyType = UIReturnKeyDone;
		input.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

        [cell addSubview:input];
        
        //Currency
        
        en = [currencyProxies objectEnumerator];
        CurrencyProxy *proxy2;
        found = NO;
        while((proxy2 = [en nextObject])) {
            if([payer isEqualToString:proxy2.name]) {
                found = YES;
                break;
            }
        }
        if(!found) {
            NSLog(@"Error: Did not find a currency proxy for payer");
        }
        
        CGRect curFrame = CGRectMake(cellFrame.size.width-CURRENCY_WIDTH-21, 11, CURRENCY_WIDTH, 26);
        UITextField *currency = [[UITextField  alloc] initWithFrame:curFrame];
        [currency setBorderStyle:UITextBorderStyleNone];
        [currency setKeyboardType:UIKeyboardTypeAlphabet];
        [currency setText:[number currency]];
        [currency setDelegate:proxy2];
        currency.returnKeyType = UIReturnKeyDone;
        [cell addSubview:currency];
        
    }
    else if(indexPath.section == 1) {
        NSString *member = [groupArray objectAtIndex:indexPath.row];
        [name setText:member];
        
    }
    else {
        NSLog(@"Too many sections");
    }
    
    [name setBackgroundColor:[UIColor clearColor]];
    
    [cell addSubview:name];
    [name release];
    
    return [cell autorelease];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [payers count];
    }
    else if(section == 1) {
        return [groupArray count];
    }
    else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 1)
        return @"Previous participants";
    else
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 1) {
        NSString *name = [groupArray objectAtIndex:indexPath.row];
        
        Money* money = [currencies money:0 currency:[GlobalCurrency get]];
        
        if(money == nil) {
            NSLog(@"Error: Money was not created properly");
        }
        else {
            [payers setObject:money forKey:name];
    
            [self updatePayers];
        }

    }
    else if(indexPath.section == 0) {
        NSString *name = [[payers allKeys] objectAtIndex:indexPath.row];
        
        [payers removeObjectForKey:name];
        
        [self updatePayers];
        
  
    }
    

}


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        return YES;
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    //Run check
    if([listener canDeleteUser:[groupArray objectAtIndex:indexPath.row]]) {
        
        //Remove user
        //a little sketchy.
        [group deleteUser:[groupArray objectAtIndex:indexPath.row]];
        [groupArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];

    }
    else {

        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"User exists in on or more bills and cannot be deleted."
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        [alert release];
        
    }
        
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1) {
        //save new user
        NSString *name = [nameField text];
        
        if([[payers allKeys] containsObject:name] && [payers count] != 0) {
            //TODO: Maybe show an alert?
            NSLog(@"TODO: Find out why this happens when list is empty");
            return;
        }
        
        Money* money = [currencies money:0 currency:[GlobalCurrency get]];
        
        if(money == nil) {
            NSLog(@"Error: Money was not created properly");
        }
        else {
        
            [payers setObject:money forKey:name];
            
            InputProxy *proxy = [[InputProxy alloc] initWithUser:name andTarget:self];
            [inputProxies addObject:proxy];
            [proxy release];
        
            CurrencyProxy *proxy2 = [[CurrencyProxy alloc] initWithUser:name andTarget:self];
            [currencyProxies addObject:proxy2];
            [proxy2 release];
        
            [group addUser:name];
        
            [self updatePayers];
            
        }
        
        [nameField setText:@""];
    }
}
/*
-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder]; 
    return YES;
}*/
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[ self.view.subviews performSelector: @selector(resignFirstResponder) ];
	
	//for(UIView* v in self.subviews){
	//	[ v resignFirstResponder ];
	//}
}*/

/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[textField resignFirstResponder];
    
    return YES;
}*/

-(BOOL)textFieldShouldReturn:textField forName:(NSString*)name {
    
    Money *oldNumber = [payers objectForKey:name];
    
    NSString *currency;
    if(oldNumber == nil) {
        currency = [GlobalCurrency get];
    }
    else {
        currency = [oldNumber currency];
    }
    
    Money *number;
    if([[textField text] isEqualToString:@""]) {
        number = [currencies money:0 currency:currency];
    }
    else {
        float f = [[textField text] floatValue];
        number = [currencies money:f currency:currency];
    }
    
    if(number == nil) {
        NSLog(@"Error: Money was not created properly");
    }
    else {
        [payers setObject:number forKey:name];
    }
        
    [textField resignFirstResponder];
    
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string forName:(NSString*)name{

    NSString *a = [textField text];
    
    NSString *b = [a stringByReplacingCharactersInRange:range withString:string];
    
    Money *oldNumber = [payers objectForKey:name];
    
    NSString *currency;
    if(oldNumber == nil) {
        currency = [GlobalCurrency get];
    }
    else {
        currency = [oldNumber currency];
    }
    
    Money *number;
    if([b isEqualToString:@""]) {
        number = [currencies money:0 currency:currency];
    }
    else {
        float f = [b floatValue];
        number = [currencies money:f currency:currency];
    }
    
    if(number == nil) {
        NSLog(@"Error: Money was not created properly");
    }
    else {
        [payers setObject:number forKey:name];
    }
    return YES;

}
/*
-(void)changeCurrencyFor:(NSString*)name {
    
    UIAlertView *inputCurrencyAlert = [[UIAlertView alloc] initWithTitle:@"Change currency" message:@"\n\n\n" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    UILabel *currencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
    currencyLabel.font = [UIFont systemFontOfSize:16];
    currencyLabel.textColor = [UIColor whiteColor];
    currencyLabel.backgroundColor = [UIColor clearColor];
    currencyLabel.shadowColor = [UIColor blackColor];
    currencyLabel.shadowOffset = CGSizeMake(0,-1);
    currencyLabel.textAlignment = UITextAlignmentCenter;
    currencyLabel.text = @"Currency";
    [inputCurrencyAlert addSubview:currencyLabel];
    
    UIImageView *alertImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"passwordfield" ofType:@"png"]]];
    alertImage.frame = CGRectMake(11,79,262,31);
    [inputCurrencyAlert addSubview:alertImage];
    
    currencyField = [[UITextField alloc] initWithFrame:CGRectMake(16,83,252,25)];
    currencyField.font = [UIFont systemFontOfSize:18];
    currencyField.backgroundColor = [UIColor whiteColor];
    currencyField.secureTextEntry = NO;
    currencyField.keyboardAppearance = UIKeyboardAppearanceAlert;
    currencyField.delegate = self;
    [currencyField becomeFirstResponder];
    [inputCurrencyAlert addSubview:nameField];
    
    
    [inputCurrencyAlert show];
    [inputCurrencyAlert release];
    [nameField release];
    [alertImage release];
    [currencyLabel release];
    
}*/

-(BOOL)currencyTextFieldShouldReturn:(UITextField*)textField forName:(NSString*)name {
    
    Money *oldNumber = [payers objectForKey:name];
    
    NSString *texten = [[textField text] uppercaseString];
    
    //NSLog(texten);
    
    if([texten isEqualToString:@""]) {
        [textField setText:[oldNumber currency]];
    } else {
        //Check if currency exists?
        Money *newNumber = [currencies money:[oldNumber amount] currency:texten];
        
        if(newNumber != nil) {
            [payers setObject:newNumber forKey:name];
            
            [textField setText:texten];
            
            //Set to new global currency
            [GlobalCurrency set:texten];
            
        }
        else {
            
            NSString *message = [NSString stringWithFormat:@"Couldn't find currency %@", [textField text]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            
            //Currency does not exist in db (or error has occured)
            [textField setText:[oldNumber currency]];
            
        }
        
    }
    
    
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)currencyTextField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string forName:(NSString*)name {

    
    NSString *a = [textField text];
    
    NSString *texten = [a stringByReplacingCharactersInRange:range withString:string];
    
    texten = [texten uppercaseString];
    
    Money *oldNumber = [payers objectForKey:name];
    
    //Check if currency exists?
    Money *newNumber = [currencies money:[oldNumber amount] currency:texten];
    
    if(newNumber != nil) {
        [payers setObject:newNumber forKey:name];
        [textField setText:texten];
        //Set to new global currency
        [GlobalCurrency set:texten];
        
        [textField resignFirstResponder];
        return NO;
        
    }

    //Only allow certain changes?
    
    return YES;
}

-(void)filledInput:(UITextField *)sender forName:(id)name{
    NSLog(@"What is this function meant to be used for?");
}


@end
