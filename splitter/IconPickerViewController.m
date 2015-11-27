//
//  IconPickerViewController.m
//  splitter
//
//  Created by Richard Hermanson on 09/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "IconPickerViewController.h"

#import "IconProxy.h"

@implementation IconPickerViewController

@synthesize pickedIcon, pickedIconLabel;

- (id)initWithListener:(id)aListener
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        listener = aListener;
        
        icons = [[NSDictionary alloc] initWithObjectsAndKeys:   
                 @"Skiing",
                 @"skidor.png",
                 @"Café",
                 @"kaffe.png",
                 @"Taxi",
                 @"taxi.png",
                 @"Flight",
                 @"flyg.png",
                 @"Food",
                 @"bestick.png",
                 @"Bus",
                 @"buss.png",
                 @"Shopping",
                 @"shopping.png",
                 @"Sport",
                 @"golf.png",
                 @"Other",
                 @"other.png",
                 @"Car",
                 @"bil.png",
                 @"Drink",
                 @"drink.png",
                 @"Hotel", //12st
                 @"hotell.png",
                 nil];
    }
    return self;
}



- (void)dealloc
{
    [icons release];
    [proxies release];
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
    [self setTitle:@"Pick an icon"];
    //UITabBarItem *item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:2];
    //[self setToolbarItems:[NSArray arrayWithObject:item]];
    
    //UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Pick icon"];
    //item.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelCreate)];
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemUndo target:self action:@selector(cancelCreate)];
    self.navigationItem.leftBarButtonItem = baritem;
    [baritem release];
    UIView *grid = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [grid setBackgroundColor:[UIColor whiteColor]];
    
    int n = [icons count];
    
    NSMutableArray *proxiesMutable = [[NSMutableArray alloc] initWithCapacity:n];
    NSArray *keys = [icons allKeys];
    NSArray *values = [icons allValues];
    for (int i = 0; i<n; i++) {
        


        UIImage *image = [UIImage imageNamed:[keys objectAtIndex:i]];
        UIButton *iconView = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [iconView setImage:image forState:UIControlStateNormal];
        [iconView setTitle:[keys objectAtIndex:i] forState:UIControlStateDisabled];
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        int totalWidth = 320;
        int totalHeight = 436;
        int width = (int)(totalWidth/3.0);
        int height = (int)(totalHeight/4.0);
        int x = width*(i%3);
        int y = height*(i/3)+65;
       
        CGRect rect = CGRectMake(x,y-20,width,height);
        UILabel *uTxtF = [[UILabel alloc] initWithFrame:CGRectMake(x, y+65, width, 20)];
           [uTxtF setTextAlignment:UITextAlignmentCenter];
        //uTxtF.textAlignment = UITextAlignmentCenter;
        [uTxtF setText:[values objectAtIndex:i]];
              
        [iconView setFrame:rect];
        
        iconView.userInteractionEnabled = YES;
        
        IconProxy *proxy = [[IconProxy alloc] initWithSender:iconView andTarget:self];

        [iconView addTarget:proxy action:@selector(clicked) forControlEvents:UIControlStateHighlighted];
        
        [proxiesMutable addObject:proxy];
       // [uTxtF release];
        [proxy release];
       
        [grid addSubview: iconView];
        [grid addSubview:uTxtF];
        [uTxtF release];
    }
    
    proxies = [NSArray arrayWithArray:proxiesMutable];
    [proxies retain];
    
    [proxiesMutable release];
    
    //[self.view addSubview:grid];
    self.view = grid;
    
    [grid release];
    
    
}

- (void) iconPicked{
	NSLog(@"WARNING: IconPickerViewController -iconPicked called but not implemented!");
}

- (void) clicked:(id)sender
{
    NSString *icon = [sender titleForState:UIControlStateDisabled];
    
    pickedIcon = icon; //TODO properly
    pickedIconLabel = [icons objectForKey:icon];
    [listener iconPicked];
}

- (void)cancelCreate
{
    [self dismissModalViewControllerAnimated:YES];
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

@end
