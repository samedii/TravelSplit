//
//  ParticipantsPickerViewController.m
//  splitter
//
//  Created by Richard Hermanson on 19/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "ParticipantsPickerViewController.h"

#import "Money.h"
#import "NSStringFormatting.h"
#import "GlobalCurrency.h"

@implementation ParticipantsPickerViewController

@synthesize participants;

- (id)initWithListener:(id)aListener currencies:(CurrencyRateFetcher *)curr andGroup:(Group *)aGroup
{
    self = [super init];
    if (self) {
        // Custom initialization
        listener = aListener;
        currencies = curr;
        group = aGroup;
        groupArray = [[NSMutableArray alloc] init];
        participants = [self _newDictionaryFromGroup];
        
        [self _refreshProxies];
        
    }
    return self;
}

-(void)_refreshProxies {
    
    specialProxies = [[NSMutableDictionary alloc] initWithCapacity:[[group getUsers] count]];
    for(NSString *name in [group getUsers]) {
        SpecialProxy *proxy = [[SpecialProxy alloc] initWithUser:name andTarget:self];
        [specialProxies setObject:proxy forKey:name];
    }
    
    
    NSArray* arr  = [group getUsers];
    
    inputProxies = [[NSMutableArray alloc] initWithCapacity:[groupArray count]];
    currencyProxies = [[NSMutableArray alloc] initWithCapacity:[groupArray count]];
    
    NSEnumerator *e = [arr objectEnumerator];
    NSString *name;
    while((name = [e nextObject])) {
        InputProxy *proxy = [[InputProxy alloc] initWithUser:name andTarget:self];
        [inputProxies addObject:proxy];
        [proxy release];
    }
    
    e = [arr objectEnumerator];
    while((name = [e nextObject])) {
        CurrencyProxy *proxy = [[CurrencyProxy alloc] initWithUser:name andTarget:self];
        [currencyProxies addObject:proxy];
        [proxy release];
    }
    
}

-(NSMutableDictionary*)_newDictionaryFromGroup {
    NSArray *arr = [group getUsers];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[arr count]];
    
    for(NSString *name in arr) {
        [dict setObject:[currencies emptyMoney] forKey:name];
    }
    return dict;
}

- (void)dealloc
{
    [participants release];
    [table release];
    [groupArray release];
    
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
    
    [self.navigationItem setTitle:@"Who participated?"];
    
    const int TABLE_HEIGHT = 352;
    
    //Participants and previous participants table
    CGRect tableFrame = CGRectMake(0, 0, 320, TABLE_HEIGHT);
    table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    [table setDataSource:self];
    [table setDelegate:self];
    [aView addSubview:table];
    
    //Menu border
    CGRect borderFrame = CGRectMake(0, TABLE_HEIGHT, 320, 1);
    UIView *border = [[UIView alloc] initWithFrame:borderFrame];
    [border setBackgroundColor:[UIColor grayColor]];
    [aView addSubview:border];
    
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
    
    [done addTarget:self action:@selector(participantPickerDone) forControlEvents:UIControlStateHighlighted];
    
    [aView addSubview:done];
    
    [self setView:aView];
    [aView release];
    [border release];
}

-(void)viewWillAppear:(BOOL)animated {
    [participants release];
    participants = [self _newDictionaryFromGroup];
    
    /*NSEnumerator *en = [groupArray objectEnumerator];
    NSString *name;
    while((name = [en nextObject])) {
        [participants removeObjectForKey:<#(id)#>];
    }*/
    [participants removeObjectsForKeys:groupArray];
    
    [self updateParticipants];
    
    [self _refreshProxies];
    
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

-(void)participantPickerDone {
    
    if([participants count] > 0) { 
        [listener participantsPicked];
    }
	else {
		UIAlertView* alert = [ [ UIAlertView alloc ] initWithTitle:@"Error" message:@"There are no participants!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
		[ alert show ];
		[ alert	release ];
	}
    //check amounts
    
}

- (void) participantsPicked {
	NSLog(@"WARNING: PayerPickerViewController -participantsPicked but not implemented!");
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


-(void)updateParticipants {
    
    [groupArray release];
    groupArray = [[NSMutableArray alloc] initWithArray:[group getUsers]];

    NSEnumerator *e = [participants keyEnumerator];
    NSString* tmpName;
    while((tmpName = [e nextObject])) {
        if([groupArray containsObject:tmpName]) {
            [groupArray removeObject:tmpName];
        }
    }
    
    
    [table reloadData];

}


-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [firstName release];
    [lastName release];
    
    if(![[participants allKeys] containsObject:name]) {
        [participants setObject:[currencies emptyMoney] forKey:name];
        
        InputProxy *proxy = [[InputProxy alloc] initWithUser:name andTarget:self];
        [inputProxies addObject:proxy];
        [proxy release];
        
        CurrencyProxy *proxy2 = [[CurrencyProxy alloc] initWithUser:name andTarget:self];
        [currencyProxies addObject:proxy2];
        [proxy2 release];
        
        SpecialProxy *proxy3 = [[SpecialProxy alloc] initWithUser:name andTarget:self];
        [specialProxies setObject:proxy3 forKey:name];
        [proxy3 release];
    
        [group addUser:name];
    
        [self updateParticipants];
    }
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect cellFrame = CGRectMake(0, 0, table.frame.size.width, 44);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:cellFrame];
    
    const int NAME_WIDTH = 155;
    const int AMOUNT_WIDTH = 60;
    const int CURRENCY_WIDTH = 40;
    const int TOGGLE_WIDTH = 40;
    
    //Name
    CGRect nameFrame = CGRectMake(19, 0, NAME_WIDTH, 44);
    UILabel *name = [[UILabel alloc] initWithFrame:nameFrame];

    if(indexPath.section == 0) {
        
        NSString *participant = [[participants allKeys] objectAtIndex:indexPath.row];
        [name setText:participant];
        
        CGRect specialRect = CGRectMake(270, 3, TOGGLE_WIDTH, TOGGLE_WIDTH);
        UIButton *special = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [special setFrame:specialRect];
        
        
        [special addTarget:[specialProxies objectForKey:participant] action:@selector(toggleEdit) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:special];
        
        
        if([[specialProxies objectForKey:participant] activated]) {
            
            //Amount
            CGRect amountFrame = CGRectMake(cellFrame.size.width-AMOUNT_WIDTH-CURRENCY_WIDTH-5-TOGGLE_WIDTH, 9, AMOUNT_WIDTH, 26);
            UITextField *input = [[UITextField alloc] initWithFrame:amountFrame];
            [input setBorderStyle:UITextBorderStyleRoundedRect];
            //[input setBackgroundColor:[UIColor redColor]];
            [input setKeyboardType:UIKeyboardTypeDecimalPad];
            Money *number = [participants objectForKey:participant];
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
                if([participant isEqualToString:proxy.name]) {
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
                if([participant isEqualToString:proxy2.name]) {
                    found = YES;
                    break;
                }
            }
            if(!found) {
                NSLog(@"Error: Did not find a currency proxy for payer");
            }
            
            CGRect curFrame = CGRectMake(cellFrame.size.width-CURRENCY_WIDTH-TOGGLE_WIDTH, 11, CURRENCY_WIDTH, 26);
            UITextField *currency = [[UITextField  alloc] initWithFrame:curFrame];
            [currency setBorderStyle:UITextBorderStyleNone];
            [currency setKeyboardType:UIKeyboardTypeAlphabet];
            [currency setText:[number currency]];
            [currency setDelegate:proxy2];
            currency.returnKeyType = UIReturnKeyDone;
            [cell addSubview:currency];
            
        }
        
        
        
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
    
    //Delete button
    //TODO
    
    
    
    return [cell autorelease];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {

        return [participants count];
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
        
        [participants setObject:[currencies emptyMoney] forKey:name];
        
        [self updateParticipants];

    }
    else if(indexPath.section == 0) {
        NSString *name = [[participants allKeys] objectAtIndex:indexPath.row];
        
        [participants removeObjectForKey:name];
        
        [self updateParticipants];
        
    }
    

}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *user;
    if(indexPath.section == 1) {
        user = [groupArray objectAtIndex:indexPath.row];
    }
    else { //section == 0
        user = [[participants allKeys] objectAtIndex:indexPath.row];
    }
    
    //Run check
    if([listener canDeleteUser:user]) {
        
        //Remove user
        //a little sketchy.
        [group deleteUser:user];
        if(indexPath.section == 1) {
            [groupArray removeObjectAtIndex:indexPath.row];
        }
        else { //section == 0
            [participants removeObjectForKey:user];
        }
        
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
        
        if([[participants allKeys] containsObject:name] && [participants count] != 0) {
            //TODO: Maybe show an alert?
            NSLog(@"TODO: Find out why this happens when list is empty");
            return;
        }
        
        if(![[participants allKeys] containsObject:name]) {
            [participants setObject:[currencies emptyMoney] forKey:name];
            
            InputProxy *proxy = [[InputProxy alloc] initWithUser:name andTarget:self];
            [inputProxies addObject:proxy];
            [proxy release];
            
            CurrencyProxy *proxy2 = [[CurrencyProxy alloc] initWithUser:name andTarget:self];
            [currencyProxies addObject:proxy2];
            [proxy2 release];
            
            SpecialProxy *proxy3 = [[SpecialProxy alloc] initWithUser:name andTarget:self];
            [specialProxies setObject:proxy3 forKey:name];
            [proxy3 release];
        
            [group addUser:name];
        
            [self updateParticipants];
            
            
        }
        
        [nameField setText:@""];
    }
}

-(void)toggleEditFor:(NSString *)user {
    
    BOOL activated = [[specialProxies objectForKey:user] activated];
    
    if(activated) {
        //clear field
        [participants setObject:[currencies emptyMoney] forKey:user];
        
        
        [[specialProxies objectForKey:user] setActivated:NO];
    }
    else {
        [[specialProxies objectForKey:user] setActivated:YES];
    }
    
    [table reloadData];
}

-(BOOL)currencyTextFieldShouldReturn:(UITextField*)textField forName:(NSString*)name {
    
    Money *oldNumber = [participants objectForKey:name];
    
    NSString *texten = [[textField text] uppercaseString];
    
    //NSLog(texten);
    
    if([texten isEqualToString:@""]) {
        [textField setText:[oldNumber currency]];
    } else {
        //Check if currency exists?
        Money *newNumber = [currencies money:[oldNumber amount] currency:texten];
        
        if(newNumber != nil) {
            [participants setObject:newNumber forKey:name];
            
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
    
    Money *oldNumber = [participants objectForKey:name];
    
    //Check if currency exists?
    Money *newNumber = [currencies money:[oldNumber amount] currency:texten];
    
    if(newNumber != nil) {
        [participants setObject:newNumber forKey:name];
        [textField setText:texten];
        //Set to new global currency
        [GlobalCurrency set:texten];
        return NO;
        
    }
    
    //Only allow certain changes?
    
    return YES;
}


-(void)filledInput:(UITextField *)sender forName:(id)name{
    NSLog(@"What is this function meant to be used for?");
}

-(BOOL)textFieldShouldReturn:textField forName:(NSString*)name {
    
    Money *oldNumber = [participants objectForKey:name];
    
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
        [participants setObject:number forKey:name];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string forName:(NSString*)name{
    
    NSString *a = [textField text];
    
    NSString *b = [a stringByReplacingCharactersInRange:range withString:string];
    
    Money *oldNumber = [participants objectForKey:name];
    
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
        [participants setObject:number forKey:name];
    }
    return YES;
    
}

@end
