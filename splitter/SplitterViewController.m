//
//  SplitterViewController.m
//  splitter
//
//  Created by Richard Hermanson on 21/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "SplitterViewController.h"
#import "TransactionViewController.h"

#import "Money.h"
#import "GlobalCurrency.h"

#import "Transaction.h"

#define GREED 0.01
//ta bort saker som är mindre än greed från listan


void increment(bool *binaries, int length)
{
    
    int i = 0;
    while(i < length) {
        if(binaries[i] == 0) {
            binaries[i] = 1;
            break;
        }
        else {
            binaries[i] = 0;
        }
        i++;
        
    }
}

bool allOnes(bool *binaries, int length) 
{

    for(int i = 0; i<length;i++) {
        if(binaries[i] == 0) {
            return FALSE;
        }
    }
    
    return TRUE;
}

@implementation SplitterViewController

- (id)initWithBalance:(NSDictionary*)aBalance currencies:(CurrencyRateFetcher *)aFetcher andListener:(id<DialogCloser>)aListener
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        
        transactions = [[NSMutableArray alloc] init];
        
        listener = aListener;
        fetcher = aFetcher;
        balance = aBalance;
        [balance retain];
        Negative = nil;
        Positive = nil;
        
        solution = nil;
        
        [self calculateOrderedBalances];
        [self calculateTransactions];
        
    }
    return self;
}

- (void)dealloc
{
    [transactions release];
    [Negative release];
    [Positive release];
    [balance release];
    [solution release];
    [super dealloc];
}



-(void)updateBalance:(NSDictionary *)aBalance {
    [balance release];
    balance = aBalance;
    [balance retain];
    
    [self calculateOrderedBalances];
    [self calculateTransactions];
    
    [self loadView];
}

-(void)calculateOrderedBalances {
    

    
    //NSArray *b = [[balance allValues] sortedArrayUsingSelector:@selector(<#selector#>)];
    
    //NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSMutableArray *orderedBalance = [NSMutableArray arrayWithArray:[[balance allValues] sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        
        
        if (fabsf([obj1 trueValue]) > fabsf([obj2 trueValue])) {
            
            return (NSComparisonResult)NSOrderedDescending;
            
        }
        
        
        
        if (fabsf([obj1 trueValue]) < fabsf([obj2 trueValue])) {
            
            return (NSComparisonResult)NSOrderedAscending;
            
        }
        
        return (NSComparisonResult)NSOrderedSame;
        
    }]];
        
    NSMutableArray *N = [[NSMutableArray alloc] init];
    NSMutableArray *P = [[NSMutableArray alloc] init];
    
    NSMutableArray *removeLater = [[NSMutableArray alloc] init];

    NSEnumerator *en = [orderedBalance objectEnumerator];
    Money *number;
    while((number = [en nextObject])) {
        int result = [[number getNumber] compare:[NSNumber numberWithInt:0]];
        if(result == NSOrderedDescending) {
            [N addObject:number];
        }
        else if(result == NSOrderedAscending) {
            [P addObject:number];
        }
        else {
            [removeLater addObject:number]; //already 0
        }
    }
    
    [orderedBalance removeObjectsInArray:removeLater];
    
    [Negative release];
    [Positive release];
    
    Negative = [NSArray arrayWithArray:N];
    Positive = [NSArray arrayWithArray:P];
    
    [N release];
    [P release];
    
    [Negative retain];
    [Positive retain];
    
}

-(void)calculateTransactions {
    
    [solution release];
    solution = [[NSMutableArray alloc] init];
    
    //int minimumTransactions = MIN([Negative count], [Positive count]);
    
    //All combinations (just like binaries)
    int length = [Negative count];
    bool binary[length];
    for (int i = 0; i<length; i++) {
        binary[i] = 0;
    }
    
    
    //use increment function to create new combinations
    
    //max number of comparisons
    
    //int faculty = 1;
    //for(int i = length; i!=0; i--) {
    //    faculty = faculty * i;
    //}
    //faculty++;
    
    //
    
    while (!allOnes(binary, length)) {
        
        increment(binary, length);
        
        //Summera delmängden
        float sum = 0;
        for(int j = 0; j<length; j++) {
            if(binary[j] == 1) {
                sum += [[Negative objectAtIndex:j] trueValue];
            }
        }
        
        //NSLog(@"sum %f", sum);    
        NSArray *resultArr = [SplitterViewController compareNumber:sum to:Positive];

        //if([result count] > 0) {
        
        
        for (NSArray *result in resultArr) {
            
            NSMutableArray *neg = [[NSMutableArray alloc] init];
            
            //Sätt ihop mängden
            for(int j = 0; j<length; j++) {
                if(binary[j] == 1) {
                    [neg addObject:[Negative objectAtIndex:j]];
                    //NSLog(@"Neg: %f", [[Negative objectAtIndex:j] floatValue]);
                }
            }
            

            
            //if members of result already present in another solution, throw it away?
            
            //Save result
            [solution addObject:[result arrayByAddingObjectsFromArray:neg]];
            
            [neg release];
            //
            //Remove numbers included in result?
            
            
        }
        
        //NSLog(@"%i", binary[0]);
        
    }
    
}

+(NSArray*)compareNumber:(float)num to:(NSArray*)numbers{
    
    //id numbers = numbers2;
    //numbers = Positive; //BUGG. ERIK FIXA PLSSSSS
    
    //
    // Kan optimeras
    //

    
    //All combinations (just like binaries)
    int length = [numbers count];
    bool binary[length];
    for (int i = 0; i<length; i++) {
        binary[i] = 0;
    }
    
    //NSLog(@"numbers %i", length);
    
    //use increment function to create new combinations
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] initWithObjects:nil];
    
    while(!allOnes(binary, length)) {
        
        increment(binary, length);

        //Summera delmängden
        float sum = 0;
        for(int j = 0; j<length; j++) {
            if(binary[j] == 1) {
                sum += [[numbers objectAtIndex:j] trueValue];
            }
        }
        

        
        if(num - GREED < -sum && -sum < num + GREED) {
            
            //NSLog(@"neg sum %f", sum);
            //NSLog(@"sum %f", num);
            
            NSMutableArray *tmp = [[NSMutableArray alloc] init];
            for(int j = 0; j<length; j++) {
                if(binary[j] == 1) {
                    [tmp addObject:[numbers objectAtIndex:j]];
                }
            }
            
            NSArray *result = [NSArray arrayWithArray:tmp];
            [tmp release];
            [resultArr addObject:result];
            
        }
        
        
    }
    
    return resultArr;
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(UIView*) createTransactionViewFrom: (NSString*)from to: (NSString*)to amount:(int) amount {
	TransactionViewController* c = [ [ [TransactionViewController alloc] init ] autorelease ];
	
	UIView* v = c.view;
	[ v retain ];
    
    //Splitting both names by space and saves the results in dictonaries
    //NSArray *fromName = [[NSArray alloc] initWithArray:[from componentsSeparatedByString:@" "]];
    //NSArray *toName = [[NSArray alloc] initWithArray:[to componentsSeparatedByString:@" "]];
    
    NSRange fromFirstSpace = [from rangeOfString:@" "];
    NSRange toFirstSpace = [to rangeOfString:@" "];
    
    //sets to labels
    if(fromFirstSpace.location == NSNotFound) {
        c.from.text = from;
        c.fromLast.text = @" ";
    }
    else {
        c.from.text = [from substringToIndex:(fromFirstSpace.location)];
        c.fromLast.text = [from substringFromIndex:(fromFirstSpace.location+1)];
    }

    /*
    if ([fromName count]>1) {
        c.fromLast.text = [fromName lastObject];
    }else{
        c.fromLast.text = @"";   
    }
     */
   /* if([fromName count]>1){
        for (int i =1; i<[fromName count]; i++) {
            c.fromLast.text = [c.fromLast.text stringByAppendingString:[fromName objectAtIndex:i]];
            c.fromLast.text = [c.fromLast.text stringByAppendingString:@" "];
        }
    }*/
    
    
    //sets to labels
    if(toFirstSpace.location == NSNotFound) {
        c.to.text = to;
        c.toLast.text = @" ";
    }
    else {
        c.to.text = [to substringToIndex:(toFirstSpace.location)];
        c.toLast.text = [to substringFromIndex:(toFirstSpace.location+1)];
    }
    
    
    
    /*
    if ([toName count]>1) {
        c.toLast.text = [toName lastObject];
    }else{
        c.toLast.text = @"";   
    }*/
    
    /*if([toName count]>1){
        for (int i =1; i<[toName count]; i++) {
            c.toLast.text = [c.toLast.text stringByAppendingString:[toName objectAtIndex:i]];
            
        }
    }*/
    
    //releases the dictonaries
    //[toName release];
    //[fromName release];
    
    
	c.amount.text = [ NSString stringWithFormat: @"%i", amount ];
    return [ v autorelease ];
	

}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    
    [transactions removeAllObjects];
    
	const int TVIEW_HEIGHT = 72;
	const int MARGIN = 24-20;
	const int START_OFFSET = 44;
    const int MENU_HEIGHT = 70; //374); //412
	
    UIView* container = [ [ UIView alloc ] initWithFrame:CGRectMake(0,0,320,480-START_OFFSET) ];
    
	container.backgroundColor = [ UIColor whiteColor ];

	/*
	 *	Nav bar
	 */
	UINavigationBar* bar = [ [ UINavigationBar alloc ] initWithFrame:CGRectMake(0, 20, 320, START_OFFSET) ];
	UINavigationItem* item = [ [ UINavigationItem alloc ] initWithTitle:@"Transactions" ];
	item.leftBarButtonItem = [ [ [ UIBarButtonItem alloc ] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf) ] autorelease ];
	
	[ bar pushNavigationItem:item animated:FALSE ];
	[ item release ];
	[ container addSubview: bar ];
	[ bar release ];
	
	/*
	 *	Scroll view setup
	 */
	UIScrollView* scrollView = [ [ UIScrollView alloc ] initWithFrame:CGRectMake(2, START_OFFSET+20, 320-2, 480 - START_OFFSET - MENU_HEIGHT-20) ];
    //scrollView.backgroundColor = [UIColor redColor];
	//UIView* inner = [ [ UIView alloc ] initWithFrame:CGRectMake(0, 0, 320, (MARGIN+TVIEW_HEIGHT)*15)];
	//[ scrollView addSubview:inner ];
	scrollView.bounces = FALSE;
	//[ inner release ];
	
	/*
	 *	Transaction views
	 */
    
    NSArray *nameSolution = [self _finalNameSolution];
    
    /*
    for (NSArray *a in nameSolution) {
        for (NSString *b in a) {
            NSLog(b);
        }
        NSLog(@"\n");
    }*/
    
    NSMutableDictionary *allUsersBalance = [[NSMutableDictionary alloc] initWithDictionary:balance];
    

    
    /*for (Money *m in [allUsersBalance allValues]) {
        NSLog([m stringValue]);
    }
    
    for (NSString *user in [allUsersBalance allKeys]) {
        NSLog(user);
    }
    
    for (NSArray *arr in nameSolution) {
        for (NSString *name in arr) {
            NSLog(name);
        }
    }*/
    
    float rate = [[fetcher getRateFor:[GlobalCurrency get]] floatValue];

    int k = 0;
    int skipped = 0;


    for( int i = 0; i < [nameSolution count]; i++ ) {
        
        NSArray *partSolution = [nameSolution objectAtIndex:i];
        
        NSMutableArray *orderedPartSolution = [NSMutableArray arrayWithArray:partSolution]; 

        //float nextAmount = 0;
        
        int number = [orderedPartSolution count]-1;
        
        for( int j = 0; j < number; j++ ) {
            
            //Reorder the names in partial solution.
            orderedPartSolution = [NSMutableArray arrayWithArray:[orderedPartSolution sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                
                
                if ([[allUsersBalance objectForKey:obj1] trueValue] > [[allUsersBalance objectForKey:obj2] trueValue]) {
                    
                    return (NSComparisonResult)NSOrderedDescending;
                    
                }
                
                
                
                if ([[allUsersBalance objectForKey:obj1] trueValue] < [[allUsersBalance objectForKey:obj2] trueValue]) {
                    
                    return (NSComparisonResult)NSOrderedAscending;
                    
                }
                
                return (NSComparisonResult)NSOrderedSame;
                
            }]];
            

            /*
            NSLog(@"AllUsersBalance:");
            for (Money *m in [allUsersBalance allValues]) {
                NSLog([m stringValue]);
            }*/
            
            NSString *name = [orderedPartSolution objectAtIndex:0];
            NSString *name2 = [orderedPartSolution objectAtIndex:[orderedPartSolution count]-1];
            

            Money *m = [allUsersBalance objectForKey:name];            
            Money *m2 = [allUsersBalance objectForKey:name2];
            
            Money *transM; //transmitted money
            
            if(fabsf([m trueValue]) < fabsf([m2 trueValue])) {
                transM = m;
            }
            else {
                transM = [Money moneyWithAmount:m2.amount relativeCurrency:m2.relativeValue andCurrency:m2.currency];
                transM = [transM subtract:m2];
                transM = [transM subtract:m2];
            }
            
            
            UIView* trans;
            
            float amount = -round([transM trueValue]*rate);
            
            trans = [ self createTransactionViewFrom:name to:name2 amount:amount];
            
            Transaction *t = [[Transaction alloc] init];
        
            t.from = name;
            t.to = name2;
            t.amount = amount;
            [transactions addObject:t];
            [t release];
            
            // nextUser = name2;
            

            
            //[allUsersBalance removeObject:[balance objectForKey:name]];
            
            //NSLog([m2 stringValue]);
            m2 = [m2 sumWith:transM];
            
            float tolerance = 0.001;
            
            [allUsersBalance setObject:m2 forKey:name2];
            if([m2 trueValue] < tolerance && [m2 trueValue] > -tolerance) {
                [orderedPartSolution removeObject:name2];
            }
            
            //NSLog(@"%@",[[allUsersBalance objectForKey:name2] stringValue]);
            
            if([m2 isEqual:[fetcher emptyMoney]]) {
                NSLog(@"Note: Solution split here. One less transaction!");
            }
            
            
            
            m = [m subtract:transM];
            [allUsersBalance setObject:m forKey:name];
            if([m trueValue] < tolerance && [m trueValue] > -tolerance) {
                [orderedPartSolution removeObject:name];
            }

            
            //[allUsersBalance removeObjectForKey:name];
            //NSLog(@"%@",[[allUsersBalance objectForKey:name] stringValue]);
            
            CGPoint pt = CGPointMake( 0, (k-skipped)*(TVIEW_HEIGHT + MARGIN));
            
            if(k == 0) {
                pt = CGPointMake( 0, (k-skipped)*(TVIEW_HEIGHT + MARGIN)+4);
            }
            
            CGRect rt = trans.frame;
            rt.origin = pt;
            trans.frame = rt;
            
            //[ inner addSubview:trans ];
            [scrollView addSubview:trans];
            
            k++;
        }

    }
    
    k = k + [nameSolution count];
    skipped = skipped + [nameSolution count];
    
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, (MARGIN+TVIEW_HEIGHT)*(k-skipped));
	[ container addSubview:scrollView ];
	[ scrollView release ];
    
    
    //Optional check
    BOOL allBalanced = YES;
    
    for(Money *m in [allUsersBalance allValues]) {
        float tolerance = 0.001;
        
        if([m trueValue] > tolerance || [m trueValue] < -tolerance) {
            allBalanced = NO;
        }
    }
    
    [allUsersBalance release];
    
    if(!allBalanced) {
        NSLog(@"Warning: Splitter algorithm maybe not working as intended");
    }
    
    /*
     *  Menu (send email/sms)
     */
    
    /*UIView *menuBox = [[UIView alloc] initWithFrame:CGRectMake(0, 480-MENU_HEIGHT, 320, MENU_HEIGHT)];
    [menuBox setBackgroundColor:[UIColor magentaColor]];
    [container addSubview:menuBox];*/
    
    CGRect sendFrame = CGRectMake(10, 480-START_OFFSET-MENU_HEIGHT+54, 140, MENU_HEIGHT-40);
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendButton setFrame:sendFrame];
    [sendButton setTitle:@"Send via e-mail" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendEmailClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [container addSubview:sendButton];
    
    CGRect sendSmsFrame = CGRectMake(170, 480-START_OFFSET-MENU_HEIGHT+54, 140, MENU_HEIGHT-40);
    UIButton *sendSmsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendSmsButton setFrame:sendSmsFrame];
    [sendSmsButton setTitle:@"Send via sms" forState:UIControlStateNormal];
    [sendSmsButton addTarget:self action:@selector(sendSmsClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [container addSubview:sendSmsButton];
    
    [self setView:container];
	[ container release ];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
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

-(void)sendEmailClicked
{  
    Class mailclass =(NSClassFromString(@"MFMailComposeViewController"));  
    if(mailclass != nil)  
    {  
        if ([mailclass canSendMail])  
        {  
            [self displayComposerSheet];  
        }  
        else  
        {  
            [self launchMailAppOnDevice];  
        }  
    }  
    else  
    {  
        [self launchMailAppOnDevice];  
    }  
}  

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error   
{   
    switch (result)  
    {  
        case MFMailComposeResultCancelled:  
        {  
            break;  
        }  
        case MFMailComposeResultSaved:  
        {  
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Mail successfully saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];  
            [alert show];  
            [alert release];  
            break;  
        }  
        case MFMailComposeResultSent:  
        {  
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Mail sent successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];  
            [alert show];  
            [alert release];  
            break;  
        }  
        case MFMailComposeResultFailed:  
        {  
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Mail sending failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];  
            [alert show];  
            [alert release];  
            break;  
        }  
        default:  
        {  
            break;  
        }  
    }  
    [self dismissModalViewControllerAnimated:YES];  
}  


-(void)displayComposerSheet  
{  
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];  
    picker.mailComposeDelegate = self;  
    [picker setSubject:@"Transactions"];   
    NSMutableString *emailBody = [[NSMutableString alloc] init];
    
    NSEnumerator *en = [transactions objectEnumerator];

    Transaction *t;
    
    while((t = [en nextObject])) {
        
        [emailBody appendFormat:@"%@ pays %i %@ to %@\n", t.from, (int)(round(t.amount)), [GlobalCurrency get], t.to];
        
    }
    
    
    [picker setMessageBody:emailBody isHTML:NO];  
    [emailBody release];
    
    [self presentModalViewController:picker animated:YES];  
    [picker release];
}  
-(void)launchMailAppOnDevice  
{  
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Mail sending failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];  
    [alert show];  
    [alert release];  
    
    /*
    
    NSString *recipients = nil; //@"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";  
    NSString *body =@"Hello World";  
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];  
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];  
    */
}  

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {

    [self dismissModalViewControllerAnimated:YES];
}

-(void)sendSmsClicked {  
    
    Class smsclass =(NSClassFromString(@"MFMessageComposeViewController"));  
    if(smsclass != nil)  
    {  
        if ([smsclass canSendText])  
        {  
            [self displaySmsComposerSheet];  
        }  
    }
    
        
} 


-(void)displaySmsComposerSheet {  

    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];  
    picker.messageComposeDelegate = self;    
    NSMutableString *emailBody = [[NSMutableString alloc] init];
    
    NSEnumerator *en = [transactions objectEnumerator];
    
    Transaction *t;
    
    while((t = [en nextObject])) {
        
        [emailBody appendFormat:@"%@ pays %i %@ to %@\n", t.from, (int)(round(t.amount)), [GlobalCurrency get], t.to];
        
    }
    
    [picker setBody:emailBody];  
    [emailBody release];
    
    [picker setRecipients:[NSArray arrayWithObjects:nil]];
    
    [self presentModalViewController:picker animated:YES];  
    [picker release];   
} 

-(void)dismissSelf {
	//TODO this is actually in violation of apple programming guidelines.
	//dissmissal should take place in a delegate or in the dialog itself
    
    NSLog(@"TODO: Find out why UIModalTransitionStyleCoverVertical isn't working");
    [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve]; //UIModalTransitionStyleCoverVertical and UIModalTransitionStylePartialCurl not working?
    
    //[self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self dismissModalViewControllerAnimated:TRUE ];
}

-(NSArray*)_namesFromSolution {
    
    //Where we are going to save the solution
    NSMutableArray *aNameSolution = [[NSMutableArray alloc] initWithCapacity:[solution count]];
    
    //Counter of how many times each name has been used
    NSMutableDictionary *allNamesPrefered = [[NSMutableDictionary alloc] initWithDictionary:balance];
    
    //Set count to 0 for all names
    for (int i = 0; i<[allNamesPrefered count]; i++) {
        [allNamesPrefered setObject:[NSNumber numberWithInt:0] forKey:[[allNamesPrefered allKeys] objectAtIndex:i]];
    }
    
    
    //For every closed ring previously found (ring meaning the sum of the members equal 0)
    for(NSArray *partSolution in solution) {
        
        //Dict with name to money
        NSMutableDictionary *allNamesDict = [[NSMutableDictionary alloc] initWithDictionary:balance];
        
        //A ring
        NSMutableArray *aPartNameSolution = [[NSMutableArray alloc] initWithCapacity:[partSolution count]];
        
        //Pair each money to a name
        for(Money *mon in partSolution) {
            
            
            NSArray *names = [allNamesDict allKeysForObject:mon];
            
            //Is there more than one match? Hopefully not since this doesn't seem to be working properly
            if([names count] > 0) {
                
                //Find name used the minimum number of times
                NSNumber *min = [NSNumber numberWithInt:100];
                for(NSString *name in names) {
                    NSNumber *comp = [allNamesPrefered objectForKey:name];
                    if([comp compare:min] == NSOrderedAscending) {
                        min = comp;
                    }
                }
                
                //Pick out minimally used name
                NSString *name = nil;
                for (NSString *n in names) {
                    if([[allNamesPrefered objectForKey:n] compare:min] == NSOrderedSame) {
                        name = n;
                    }
                }
                
                if(name == nil) {
                    NSLog(@"Error: Bad programming");
                }
                
                //Increment number of uses of that name
                NSNumber *newNumber = [NSNumber numberWithInt:([min intValue]+1)];

                [aPartNameSolution addObject:name];
                [allNamesDict removeObjectForKey:name]; //not sure if needed?
                [allNamesPrefered setObject:newNumber forKey:name];
            }
            else {
                NSLog(@"Error: Couldn't find name corresponding to debt");
            }
            
        }
        
        [aNameSolution addObject:aPartNameSolution];
        [aPartNameSolution release];
        
        [allNamesDict release];
        
    }
    
    [allNamesPrefered release];
    
    return [aNameSolution autorelease];
    
}

-(NSArray*)_finalNameSolution {
    
    
    NSMutableArray *allSolutions = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSArray *nameSolution = [self _namesFromSolution];
    
    NSArray *allNames = [balance allKeys];
    
    
    int length = [nameSolution count];
    bool binary[length];
    for (int i = 0; i<length; i++) {
        binary[i] = 0;
    }
    
    //use increment function to create new combinations
    
    
    while(!allOnes(binary, length)) {
        
        NSMutableArray *tmpUsers = [[NSMutableArray alloc] initWithArray:allNames];
        
        increment(binary, length);
        

        
        //Summera delmängden
        BOOL overlap = NO;
        
        for(int j = 0; j<length; j++) {
            if(binary[j] == 1) {
                NSArray *partSolution = [nameSolution objectAtIndex:j];
                for(NSString *name in partSolution) {
                    if([tmpUsers containsObject:name]) {
                        [tmpUsers removeObject:name];
                    }
                    else {
                        overlap = YES;
                        break;
                    }
                }
            }
            if(overlap) {
                //NSLog(@"Note: Solution overlapped");
                break;
            }
        }
        
        //invalid solution, continue
        if(overlap) {
            [tmpUsers release];
            continue;
        }
        
        if([tmpUsers count] == 0) {
            //Solution found!
            
            //Creating solution array
            NSMutableArray *aSolution = [[NSMutableArray alloc] init];
            for(int j = 0; j<length; j++) {
                if(binary[j] == 1) {
                    [aSolution addObject:[nameSolution objectAtIndex:j]];
                }
            }
            
            //saving array
            [allSolutions addObject:aSolution];
            
            [aSolution release];
            
        }
        
        [tmpUsers release];
    
    }
    
    int max = 0;
    for(NSArray *arr in allSolutions) {
        if([arr count] > max) {
            max = [arr count];
        }
    }
    
    NSArray *finalSolution = nil;
    
    for(NSArray *arr in allSolutions) {
        if([arr count] == max) {
            finalSolution = arr;
            break;
        }
    }
    
    NSLog(@"%i",max);
    
    [allSolutions autorelease];
    
    return finalSolution;
}


@end
