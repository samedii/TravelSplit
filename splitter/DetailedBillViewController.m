//
//  DetailedBillViewController.m
//  splitter
//
//  Created by Richard Hermanson on 21/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "DetailedBillViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "UIScrollViewDetectTouches.h"

#define PICTURE_WIDTH -5//80
#define PICTURE_HEIGHT 80
#define BORDER_SIZE 5
#define NAV_BAR_HEIGHT 44+20
#define STATUS_BAR_HEIGHT 20


@implementation DetailedBillViewController


- (id)initWithBill:(Bill *)aBill andListener:(id)aListener
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        bill = aBill;
        [bill retain];
        listener = aListener;
    }
    return self;
}

- (void)dealloc
{
    [retakePicButton release];
    [titleField release];
    [bill release];
    [descriptionTxtField release];
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
    
    CGRect realRect = CGRectMake(0, 0, 320, 480);
    UIView *realView = [[UIView alloc] initWithFrame:realRect];
    
    CGRect aRect = CGRectMake(0, NAV_BAR_HEIGHT, 320, 480-NAV_BAR_HEIGHT-STATUS_BAR_HEIGHT);
    UIScrollViewDetectTouches *aView = [[UIScrollViewDetectTouches alloc] initWithFrame:aRect andListener:self];
    [aView setBackgroundColor:[UIColor whiteColor]];
    
    //
    //Navigation bar

    
    CGRect navFrame = CGRectMake(0, 0, 320, NAV_BAR_HEIGHT);
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navFrame];
    
    UINavigationItem *item1 = [[UINavigationItem alloc] initWithTitle:bill.title];
    //UINavigationItem *item2 = [[UINavigationItem alloc] initWithTitle:@""];
    
    [navBar pushNavigationItem:item1 animated:NO];
    //[navBar pushNavigationItem:item2 animated:NO];
    
    UIBarButtonItem *it = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
    
    UIBarButtonItem *it2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeBill)];
                           
    [item1 setLeftBarButtonItem:it];
    [item1 setRightBarButtonItem:it2];

    
    //title view of nav bar
   
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 220, 24)];
    [field setBorderStyle:UITextBorderStyleNone];
    //[field setTextColor:[UIColor whiteColor]];
    [field setTextAlignment:UITextAlignmentCenter];
    
    [field setFont:[UIFont boldSystemFontOfSize:20]];
    //[field setBackgroundColor:[UIColor redColor]];
    
    [field setText:bill.title];
    [field setDelegate:self];
    
    titleField = field;
    [field retain];
    
    [item1 setTitleView:field];
    [field release];
    
    
    [realView addSubview:navBar];
    
    [item1 release];
    [it release];
    [it2 release];
    [navBar release];
    
    
    //
    //Icon
    const int sizeOfIcon = 80;
    
    UIImage *iconImg = [UIImage imageNamed:bill.iconName];
    UIImageView *icon = [[UIImageView alloc] initWithImage:iconImg];
    //resize if needed
    [icon sizeThatFits:CGSizeMake(sizeOfIcon, sizeOfIcon)];
    //set frame for icon
    CGRect iconFrame = CGRectMake(10, 10, iconImg.size.width, iconImg.size.height);
    [icon setFrame:iconFrame];
    [aView addSubview:icon];
    [icon release];
    

    //Amount
    
    CGRect amountFrame = CGRectMake(sizeOfIcon, 10, 320-sizeOfIcon-5, 40);
    UILabel *amount = [[UILabel alloc] initWithFrame:amountFrame];
    
    [amount setText:[NSString stringWithFormat:@"Total: %@", [bill.amount stringValue]]];
    [amount setFont:[[amount font] fontWithSize:35.0]];
    [amount setAdjustsFontSizeToFitWidth:YES];
    [amount setNumberOfLines:1];
    [amount adjustsFontSizeToFitWidth];
    //[amount setBackgroundColor:[UIColor redColor]];
    
    [aView addSubview:amount];
    [amount release];
    
    //Date
	NSDateFormatter* formatter = [ [ NSDateFormatter alloc ] init];
	[ formatter autorelease ];
	[ formatter setDateStyle:NSDateFormatterShortStyle ];
	[ formatter setTimeStyle:NSDateFormatterShortStyle ];
	[ formatter setLocale:[NSLocale currentLocale]];


    CGRect dateFrame = CGRectMake(sizeOfIcon+5, 50, 320-sizeOfIcon, 20);
    UILabel *date = [[UILabel alloc] initWithFrame:dateFrame];
    NSString *date2 = [ formatter stringFromDate:bill.date ];//[bill.date description];
    
    //date2 = [dateFormatter stringFromDate:bill.date];
    //date2 = [formatter stringFromDate:[dateFormatter dateFromString:date2]];
    //NSArray *split = [date2 componentsSeparatedByString:@" "];
    [date setText:date2];//[split objectAtIndex:0]];
    //[date setTextAlignment:UITextAlignmentRight];
    //[amount setFont:[[date font] fontWithSize:40.0]];
  
    [aView addSubview:date];
    [date release];
    
    //Paid
    CGRect bFrame = CGRectMake(10, sizeOfIcon, 320, 20);
    UILabel *b = [[UILabel alloc] initWithFrame:bFrame];
    [b setText:@"Payers"];
    [aView addSubview:b];
    [b release];
    
    //Payers
    
    const int BUYER_HEIGHT = 22;

    
    NSEnumerator *en = [bill.buyers keyEnumerator];
    
    int i = 0;
    NSString *name;
    while((name = [en nextObject])) {
        
        CGRect buyerFrame = CGRectMake(10, bFrame.origin.y+20+i*BUYER_HEIGHT, 180, BUYER_HEIGHT);
        UILabel *buyer = [[UILabel alloc] initWithFrame:buyerFrame];
        [buyer setTextAlignment:UITextAlignmentRight];
        [buyer setText:name];
        [aView addSubview:buyer];
        [buyer release];
        
        CGRect smallAmountFrame = CGRectMake(20+180, bFrame.origin.y+20+i*BUYER_HEIGHT, 90, BUYER_HEIGHT);
        UILabel *smallAmount = [[UILabel alloc] initWithFrame:smallAmountFrame];
        [smallAmount setText:[[bill.buyers objectForKey:name] stringValue]];
        [aView addSubview:smallAmount];
        [smallAmount release];
        i++;
    }
    
    int TOTAL_BUYER_HEIGHT = i*BUYER_HEIGHT;

    //Participated
    CGRect pFrame = CGRectMake(10, sizeOfIcon + TOTAL_BUYER_HEIGHT + 30, 320, 20);
    UILabel *p = [[UILabel alloc] initWithFrame:pFrame];
    [p setText:@"Participants"];
    [aView addSubview:p];
    [p release];
    
    
    //Participants
    
    const int PARTICIPANT_HEIGHT = 22;
    
    
    en = [bill.participants keyEnumerator];
    
    i = 0;
    while((name = [en nextObject])) {
        
        //buyer is participant here
        CGRect buyerFrame = CGRectMake(30, bFrame.origin.y+35+20+i*PARTICIPANT_HEIGHT+TOTAL_BUYER_HEIGHT, 290, BUYER_HEIGHT);
        UILabel *buyer = [[UILabel alloc] initWithFrame:buyerFrame];
        //[buyer setTextAlignment:UITextAlignmentRight];
        
        Money *number = [bill.participants objectForKey:name];
        
        int result = [[number getNumber] compare:[NSNumber numberWithInt:0]];
        if(result == NSOrderedSame) {
            [buyer setText:name];            
        }
        else {
            [buyer setText:[NSString stringWithFormat:@"%@ %@", name, [number stringValue]]];
        }
        

        [aView addSubview:buyer];
        [buyer release];
        i++;
    }
    
    //sets properties for the description textfield
    descriptionTxtField=nil;
    
    
    //
    //Description
    
    int height = bFrame.origin.y+35+20+i*PARTICIPANT_HEIGHT+TOTAL_BUYER_HEIGHT;
    
    CGRect textFrame;
    
    if(height > 480-NAV_BAR_HEIGHT-STATUS_BAR_HEIGHT-PICTURE_HEIGHT-2*BORDER_SIZE) {
        textFrame = CGRectMake(BORDER_SIZE, 410-PICTURE_HEIGHT+NAV_BAR_HEIGHT, 320-PICTURE_WIDTH-3*BORDER_SIZE, PICTURE_HEIGHT);
    }
    else {
        textFrame = CGRectMake(BORDER_SIZE, 370/*height+BORDER_SIZE+NAV_BAR_HEIGHT*/, 320-PICTURE_WIDTH-3*BORDER_SIZE, PICTURE_HEIGHT);
    }
        
    descriptionTxtField = nil;
    descriptionTxtField = [[UITextView alloc]initWithFrame:textFrame];
    [descriptionTxtField setDelegate:self];
    [descriptionTxtField setOpaque:NO];
    [descriptionTxtField setBackgroundColor:[UIColor whiteColor]];
    descriptionTxtField.layer.borderWidth = 1;
    descriptionTxtField.layer.borderColor = [[UIColor grayColor] CGColor];
    descriptionTxtField.layer.cornerRadius = 5.0;
    descriptionTxtField.clipsToBounds = YES;
    if ([bill.description isEqualToString:@""]) {
        descriptionTxtField.text = @"Description";
        descriptionTxtField.textColor = [UIColor lightGrayColor];
    }else{
        descriptionTxtField.text = bill.description;
    }
        
    descriptionTxtField.textAlignment = UITextAlignmentLeft;

    [realView addSubview:descriptionTxtField];
    //[txtF release];
    descriptionTxtField.textAlignment = UITextAlignmentLeft;


    
    //
    //Picture
    /*
    CGRect picFrame;
    
    if(height > 480-NAV_BAR_HEIGHT-STATUS_BAR_HEIGHT-PICTURE_HEIGHT-2*BORDER_SIZE) {
        picFrame = CGRectMake(320-PICTURE_WIDTH-BORDER_SIZE, 410-PICTURE_HEIGHT+NAV_BAR_HEIGHT, PICTURE_WIDTH, PICTURE_HEIGHT);
    }
    else {
        picFrame = CGRectMake(320-PICTURE_WIDTH-BORDER_SIZE, 370, PICTURE_WIDTH, PICTURE_HEIGHT);
    }
    
    picture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [picture retain];
    [picture setFrame:picFrame];
    UIImage *btnImage;
    if(bill.img) {
        btnImage = bill.img;
    }
    else {
        btnImage = [UIImage imageNamed:@"camera-icon.jpg"];
    }
    [picture setImage:btnImage forState:UIControlStateNormal];
    [picture addTarget:self action:@selector(switchPicture) forControlEvents:UIControlEventTouchUpInside];
    
    
    [realView addSubview:picture];*/
    
    /*
    //
    //Title
    CGRect titleFrame = CGRectMake(sizeOfIcon, NAV_BAR_HEIGHT+10, 100, 30);
    UILabel *title = [[UILabel alloc] initWithFrame:titleFrame];
    [title setText:bill.title];
    
    [aView addSubview:title];
    */
    
    [aView setContentSize:CGSizeMake(320, height+descriptionTxtField.frame.size.height+10)];
    
    [realView addSubview:aView];
    
    [realView bringSubviewToFront:descriptionTxtField];
    [realView bringSubviewToFront:picture];
    
    [self setView:realView];
    [aView release];
    [realView release];
    
    
    //Premade: Retake picture button
    retakePicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [retakePicButton retain];
    CGRect retakeFrame = CGRectMake(320-80-5, 5, 80, 40);
    [retakePicButton setFrame:retakeFrame];
    [retakePicButton setTitle:@"Retake" forState:UIControlStateNormal];
    [retakePicButton addTarget:self action:@selector(retakePicture) forControlEvents:UIControlEventTouchUpInside];
    
}

//To move the textfield back to the original position(at the bottom of the view)
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"Warning: Deprecated. This should not detect");
    NSLog(@"touch ended");  
    [descriptionTxtField resignFirstResponder];

}

-(void)detectedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //NSLog(@"touch ended");  
    
    //Resetting text fields
    
    /*
    if([bill.description isEqualToString:@""]) {
        [descriptionTxtField setText:@"Description"];
    }
    else {
        [descriptionTxtField setText:bill.description];
    }
     */
    
    //Description
    [descriptionTxtField setText:bill.description];
    
    
    //Title
    [titleField setText:bill.title];
    
    
    [descriptionTxtField resignFirstResponder]; 
    [titleField resignFirstResponder];
}

//Description method
-(void)textViewDidBeginEditing:(UITextView *) textView{

    if ([bill.description isEqualToString:@""]) {
        descriptionTxtField.text=@"";
        descriptionTxtField.textColor = [UIColor blackColor];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    descriptionTxtField.frame = CGRectMake(descriptionTxtField.frame.origin.x, descriptionTxtField.frame.origin.y -260, descriptionTxtField.frame.size.width+BORDER_SIZE+PICTURE_WIDTH, descriptionTxtField.frame.size.height+40);
    [UIView commitAnimations]; 

}

//Description method
-(void)textViewDidEndEditing:(UITextView *)textField{
    
    Bill *newBill = [listener newDesc:descriptionTxtField.text toBill:bill];
    [newBill retain];
    [bill release];
    bill = newBill;

    
    if (descriptionTxtField.text.length == 0) {
        descriptionTxtField.text = @"Description";
        descriptionTxtField.textColor = [UIColor lightGrayColor];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    descriptionTxtField.frame = CGRectMake(descriptionTxtField.frame.origin.x, descriptionTxtField.frame.origin.y +260, descriptionTxtField.frame.size.width-BORDER_SIZE-PICTURE_WIDTH, descriptionTxtField.frame.size.height-40);
    [UIView commitAnimations];
}

-(void)dismissSelf {
    [self dismissModalViewControllerAnimated:YES];
}

//removes a bill.
-(void)removeBill {
    [listener removeBill:bill];
    [self dismissSelf];
}


//Title method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([textField.text isEqualToString:@""]) {
        //reset
        [textField setText:bill.title];
        [textField resignFirstResponder];
    }
    
    //Commit changes
    Bill *newBill = [listener newTitle:textField.text toBill:bill];
    [newBill retain];
    [bill release];
    bill = newBill;
    
    //End edit
    [textField resignFirstResponder];
    
    return YES;
}

//Title method
-(BOOL)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setText:@""];
    return YES;
}

-(void)retakePicture {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        // Delegate is self
        [imagePicker setDelegate:self];
        
        // Allow editing of image ?
        //imagePicker.allowsImageEditing = NO;
        
        // Show image picker
        [self presentModalViewController:imagePicker animated:YES];
        
        [imagePicker autorelease];
        
    }

    
}

-(void)switchPicture {
    
    if(bill.img) {
 
        if(picture.frame.size.width == 320) {
            [retakePicButton removeFromSuperview];
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        if(picture.frame.size.width == 320) {
            picture.frame = CGRectMake(320-PICTURE_WIDTH-BORDER_SIZE, 410-PICTURE_HEIGHT+NAV_BAR_HEIGHT-3, PICTURE_WIDTH, PICTURE_HEIGHT);
        }
        else {
            picture.frame = CGRectMake(0, 0, 320, 480-STATUS_BAR_HEIGHT);
            
            [self.view addSubview:retakePicButton];
            [self.view bringSubviewToFront:retakePicButton];
        }
        


        
        [UIView commitAnimations];
        
    }
    else {
        
        [self retakePicture];
        
    }

}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Save image to bill/Users/y/Documents/Direwolf/split/splitter/DetailedBillViewController.m:490:1: error: unterminated comment

    Bill *newBill = [listener newImage:image toBill:bill];
    [bill release];
    [newBill retain];
    bill = newBill;
    
    [picture setImage:image forState:UIControlStateNormal];
    
    [self dismissModalViewControllerAnimated:YES];
    
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    
        //Allocating the keyboardtoolbar and setting size
        UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        
        
        //creating extra space to move to doneButton to the right
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        //creating the done button
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
                  
        //creating an array of the buttonitems and adding them to the toolbar
        NSArray *arr =[[NSArray alloc] initWithObjects:extraSpace,doneButton, nil];
        [keyboardToolbar setItems:arr];
        [arr release];
        
        [doneButton release];
       [extraSpace release];
        
        
        
    
    //set the toolbar as the textfields accessoryView
    descriptionTxtField.inputAccessoryView = keyboardToolbar;
    [keyboardToolbar release];
}

-(void)resignKeyboard:(id)sender
{
    if([descriptionTxtField isFirstResponder]){
        [descriptionTxtField resignFirstResponder];
    }
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
