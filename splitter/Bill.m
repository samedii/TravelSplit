//
//  Bill.m
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "Bill.h"


@implementation Bill

@synthesize date, buyers, participants, amount, iconName, title, creator, description, img;

-(id) initWithDate:(NSDate*)aDate isYours:(BOOL)isYours buyers:(NSDictionary*)someBuyers participants:(NSDictionary*)someParticipants amount:(Money*)anAmount icon:(NSString*)anIconName andTitle:(NSString*)aTitle
{
    self = [super init];
    if(self)
    {
        
        if([someBuyers count] == 0) {
            NSLog(@"Error: Bill with no buyers");
        }
        
        [Bill isValidDict:someBuyers];
        [Bill isValidDict:someParticipants];


        date = aDate;
        creator = isYours;
        buyers = someBuyers;
        participants = someParticipants;
        amount = anAmount;
        //currency
        iconName = anIconName;
        title = aTitle;
        description = @"";
        img = nil;
        
        [date retain];
        [buyers retain];
        [participants retain];
        [amount retain];
        [iconName retain];
        [title retain];
        [description retain];
          
    }
    
    return self;
}

+(BOOL) isValidDict:(NSDictionary*)dict {
    
    BOOL valid = TRUE;
    
    NSArray *arr = [dict allKeys];
    
    for(int i = 0; i<[arr count]; i++) {

        if(![[arr objectAtIndex:i] isKindOfClass:[NSString class]]) {
            NSLog(@"Error: this shouldn't be possible");
            valid = FALSE;
        }
        
        id something = [dict objectForKey:[arr objectAtIndex:i]];
        if(!([something isMemberOfClass:[Money class]] || something == nil)) {
            NSLog(@"Error: something in dict is not money but: %@", NSStringFromClass([something class]));
            valid = FALSE;
        }
        
    }
    
    return valid;
}
 
-(id) initWithDate:(NSDate *)aDate isYours:(BOOL)isYours buyers:(NSDictionary *)someBuyers participants:(NSDictionary *)someParticipants amount:(Money *)anAmount icon:(NSString *)anIconName title:(NSString *)aTitle andDesc:(NSString *)desc{
    self = [self initWithDate:aDate isYours:isYours buyers:someBuyers participants:someParticipants amount:anAmount icon:anIconName andTitle:aTitle];
    if(self)
    {
        description = desc;
        [description retain];
    }           

    return self;
}

-(id) initWithDate:(NSDate *)aDate isYours:(BOOL)isYours buyers:(NSDictionary *)someBuyers participants:(NSDictionary *)someParticipants amount:(Money *)anAmount icon:(NSString *)anIconName title:(NSString *)aTitle desc:(NSString *)desc andImage:(UIImage*)anImage{
    self = [self initWithDate:aDate isYours:isYours buyers:someBuyers participants:someParticipants amount:anAmount icon:anIconName title:aTitle andDesc:desc];
    if(self)
    {
        img = anImage;
        [img retain];
    }           
    
    return self;
}



-(Bill*)billWithNewDescription:(NSString*)newDesc {
    Bill *new = [[Bill alloc] initWithDate:self.date isYours:self.creator buyers:self.buyers participants:self.participants amount:self.amount icon:self.iconName title:self.title desc:newDesc andImage:self.img];

    return [new autorelease];
}

-(Bill*)billWithNewTitle:(NSString*)newTitle {
    Bill *new = [[Bill alloc] initWithDate:self.date isYours:self.creator buyers:self.buyers participants:self.participants amount:self.amount icon:self.iconName title:newTitle desc:self.description andImage:self.img];
    
    return [new autorelease];
}

-(Bill*)billWithNewImage:(UIImage*)newImage {
    Bill *new = [[Bill alloc] initWithDate:self.date isYours:self.creator buyers:self.buyers participants:self.participants amount:self.amount icon:self.iconName title:self.title desc:self.description andImage:newImage];
    
    return [new autorelease];
}


-(id)initWithCoder:(NSCoder *)coder
{

    NSDate *date2 = [coder decodeObjectForKey:@"BillDate"];
        
    NSDictionary *buyers2 = [coder decodeObjectForKey:@"BillBuyers"];
        
    NSDictionary *participants2 = [coder decodeObjectForKey:@"BillParticipants"];
            
    Money *amount2 = [coder decodeObjectForKey:@"BillAmount"];
        
    BOOL creator2 = [coder decodeBoolForKey:@"BillCreator"];
        
    NSString *iconName2 = [coder decodeObjectForKey:@"BillIconName"];
        
    NSString *title2 = [coder decodeObjectForKey:@"BillTitle"];
    
    NSString *description2 = [coder decodeObjectForKey:@"BillDescription"];
    
    
    NSData *imgData = [coder decodeObjectForKey:@"BillImage"];
    UIImage *img2 = [UIImage imageWithData:imgData];
    
    return [self initWithDate:date2 isYours:creator2 buyers:buyers2 participants:participants2 amount:amount2 icon:iconName2 title:title2 desc:description2 andImage:img2];

}



- (void)encodeWithCoder:(NSCoder *)coder {
    
    //[super encodeWithCoder:coder];
    
    [coder encodeObject:date forKey:@"BillDate"];
    
    [coder encodeObject:buyers forKey:@"BillBuyers"];
    
    [coder encodeObject:participants forKey:@"BillParticipants"];
    
    [coder encodeObject:amount forKey:@"BillAmount"];
    
    [coder encodeBool:creator forKey:@"BillCreator"];
    
    [coder encodeObject:iconName forKey:@"BillIconName"];
    
    [coder encodeObject:title forKey:@"BillTitle"];
    
    [coder encodeObject:description forKey:@"BillDescription"];
    
    NSData *imgData = UIImagePNGRepresentation(img);
    [coder encodeObject:imgData forKey:@"BillImage"];

}

-(void)dealloc
{
    [date release];
    [buyers release];
    [participants release];
    [amount release];
    [iconName release];
    [title release];
    [description release];
    [img release];
    [super dealloc];
}

@end
