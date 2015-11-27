//
//  BillView.m
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "BillView.h"

#define percentCovered (int)80

@implementation BillView

- (id)initWithFrame:(CGRect)frame listener:(id)aListener andBill:(Bill*)aBill
{
    
    listener = aListener;
    
    //style constants
    int padding = 15;
    int sizeOfIcon = 64;
    int sizeOfTitle = 20;
    int sizeOfAmount = 14;
    int sizeOfText = 0;//14;
    
    if(aBill.creator)
        frame = CGRectMake(frame.origin.x+(100.0-percentCovered)/100*frame.size.width, 
                           frame.origin.y, 
                           frame.size.width*percentCovered/100.0, 
                           sizeOfIcon+sizeOfText+2*padding);
    else
        frame = CGRectMake(frame.origin.x,
                           frame.origin.y, 
                           frame.size.width*percentCovered/100.0, 
                           sizeOfIcon+sizeOfText+2*padding);

    
    self = [super initWithFrame:frame];
    if (self) {
		bill = aBill;
		[ bill retain ];
        // Initialization code
    
		const int LEFT_OFFSET = 10;

        
        [self setBackgroundColor:[UIColor clearColor]];
        
        //NSDate *date; ej med?
        //NSArray *buyers;
        //NSArray *participants;
        //float amount;
        //UIImage *icon;
        //NSString *title;
        
        isGreen = aBill.creator;
		
		CGRect containerFrame = CGRectMake(isGreen ? -10 : 0, 0, frame.size.width, frame.size.height);
		UIView* container = [ [ [ UIView alloc ] initWithFrame:containerFrame ] autorelease ];
		[ self addSubview: container ];
        
        UIImage *iconImg = [UIImage imageNamed:aBill.iconName];
        /*
        CGRect iconFrame = CGRectMake(0,0,sizeOfIcon,sizeOfIcon);
        IconView *icon = [[IconView alloc] initWithFrame:iconFrame andImage:iconImg];
        */
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:iconImg];
        //resize if needed
        [icon sizeThatFits:CGSizeMake(sizeOfIcon, sizeOfIcon)];
        //set frame for icon
        CGRect iconFrame = CGRectMake(LEFT_OFFSET + padding, padding, iconImg.size.width, iconImg.size.height);
        [icon setFrame:iconFrame];
        
         
         [container addSubview:icon];
        [icon release];
        
        
        CGRect titleFrame = CGRectMake(iconImg.size.width+padding+LEFT_OFFSET + 3, padding + 5 - 4, frame.size.width-2*padding-iconImg.size.width, sizeOfTitle+4);
        UILabel *title = [[UILabel alloc] initWithFrame:titleFrame];
        [title setText:aBill.title];
        [title setFont:[UIFont fontWithName:@"Helvetica" size:sizeOfTitle]];
        [title setBackgroundColor:[UIColor clearColor]];
        [container addSubview:title];
        [title release];
        
        CGRect amountFrame = CGRectMake(LEFT_OFFSET + iconImg.size.width+padding + 7, 2*padding+sizeOfTitle - 4, frame.size.width-2*padding-iconImg.size.width, sizeOfAmount);
        UILabel *amount = [[UILabel alloc] initWithFrame:amountFrame];
        amount.textColor = [ UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f ];
		[amount setText:[NSString stringWithFormat:@"Total: %@", [aBill.amount stringValue]]];
        [amount setBackgroundColor:[UIColor clearColor]];
        [container addSubview:amount];
        [amount release];
        
        /*
        
        CGRect buyersFrame = CGRectMake(LEFT_OFFSET + padding, icon.frame.origin.y + icon.frame.size.width + 5, frame.size.width-2*padding, sizeOfText);
        UILabel *buyers = [[UILabel alloc] initWithFrame:buyersFrame];
        NSMutableString *buyersString = [[NSMutableString alloc] initWithString:@"Paid: "];
        for (NSString *buyer in aBill.buyers) {
            [buyersString appendFormat:@"%@ ", buyer];
        }
        [buyers setText:buyersString];
        [buyersString release];
        [container addSubview:buyers];
        [buyers release];
		buyers.backgroundColor = [ UIColor clearColor ];
         
         */
        
		const int NPARTICIPANTS_WIDTH = 10, PARTICIPANTSICON_WIDTH = 32;
		const int PARTICIPANTS_LEFT   = 213,
		          PARTICIPANTS_TOP    = 18,
		          PARTICIPANTS_MARGIN = 2,
		          PARTICIPANTS_WIDTH  = NPARTICIPANTS_WIDTH + PARTICIPANTSICON_WIDTH + PARTICIPANTS_MARGIN,
		          PARTICIPANTS_HEIGHT = 15;
		
		/*
		 *	Initialize the 'main' participants view
		 */
		CGRect participantsFrame = CGRectMake(PARTICIPANTS_LEFT, PARTICIPANTS_TOP, PARTICIPANTS_WIDTH, PARTICIPANTS_HEIGHT);
		UIView* participantsView = [ [ [ UIView alloc ] initWithFrame:participantsFrame ] autorelease ];
		
		// the participants label
        CGRect nParticipantsFrame = CGRectMake(0, 0, NPARTICIPANTS_WIDTH, PARTICIPANTS_HEIGHT);
        UILabel *nParticipants = [ [[UILabel alloc] initWithFrame:nParticipantsFrame] autorelease ];
        [nParticipants setText:[NSString stringWithFormat:@"%i", [aBill.participants count]]];
		nParticipants.backgroundColor = [ UIColor clearColor ];
		
		//the participants image view
		UIImage* partIcon = [ UIImage imageNamed:@"people.png" ];
		UIImageView* participantsIcon = [ [ [ UIImageView alloc ] initWithImage: partIcon ] autorelease ];
		CGRect tempFrame = participantsIcon.frame;
		tempFrame.origin.x = NPARTICIPANTS_WIDTH + PARTICIPANTS_MARGIN;
		tempFrame.origin.y = 2;
		participantsIcon.frame = tempFrame;
		
		[ participantsView addSubview: participantsIcon ];
		[ participantsView addSubview: nParticipants ];
		
		[ container addSubview:participantsView ];
        

        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)drawRect:(CGRect) aRect {
    
    UIImage* balloon;
    UIImage *bg;
    if(isGreen)
    {
        bg = [UIImage imageNamed:@"balloon.png"];
        balloon = [bg stretchableImageWithLeftCapWidth:15  topCapHeight:15];
    }
    else
    {
        bg = [UIImage imageNamed:@"balloon2.png"];
        balloon = [bg stretchableImageWithLeftCapWidth:28  topCapHeight:15]; //43-15 = 13+15 = 28
    }
    
    [balloon drawInRect: aRect];
}

    
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

        if ([[event allTouches] count]==1) {
            NSLog(@"%i", [bill retainCount]);
            [listener clickedBill:bill];
        }
    
	
}


- (void)dealloc
{
	[ bill release ];
    [super dealloc];
}

@end
