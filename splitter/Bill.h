//
//  Bill.h
//  splitter
//
//  Created by Richard Hermanson on 05/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Money.h"


@interface Bill : NSObject <NSCoding> {
    NSDate *date;
    BOOL creator;
    NSDictionary *buyers;
    NSDictionary *participants;
    Money *amount; //float...?
    //currency
    NSString *iconName;
    NSString *title;
    NSString *description;
    UIImage *img;

}

@property (readonly) NSDate *date;
@property (readonly) BOOL creator;
@property (readonly) NSDictionary *participants;
@property (readonly) NSDictionary *buyers;
@property (readonly) Money *amount;
@property (readonly) NSString *iconName;
@property (readonly) NSString *title;
@property (readonly) NSString *description;
@property (readonly) UIImage *img;


-(id) initWithDate:(NSDate*)aDate isYours:(BOOL)isYours buyers:(NSDictionary*)someBuyers participants:(NSDictionary*)someParticipants amount:(Money*)anAmount icon:(NSString*)anIconName andTitle:(NSString*)aTitle;

-(id) initWithDate:(NSDate*)aDate isYours:(BOOL)isYours buyers:(NSDictionary*)someBuyers participants:(NSDictionary*)someParticipants amount:(Money*)anAmount icon:(NSString*)anIconName title:(NSString*)aTitle andDesc:(NSString*)desc;

-(id) initWithDate:(NSDate *)aDate isYours:(BOOL)isYours buyers:(NSDictionary *)someBuyers participants:(NSDictionary *)someParticipants amount:(Money *)anAmount icon:(NSString *)anIconName title:(NSString *)aTitle desc:(NSString *)desc andImage:(UIImage*)anImage;

//-(id) addTitle:(Bill*)bill desc:(NSString*)desc;
-(Bill*)billWithNewDescription:(NSString*)desc;
-(Bill*)billWithNewTitle:(NSString*)title;
-(Bill*)billWithNewImage:(UIImage*)image;

+(BOOL) isValidDict:(NSDictionary*)dict;

@end
