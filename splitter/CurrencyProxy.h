//
//  CurrencyProxy.h
//  splitter
//
//  Created by Richard Hermanson on 29/01/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CurrencyProxyListener <NSObject>

-(BOOL)currencyTextField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string forName:(NSString *)name;

-(BOOL)currencyTextFieldShouldReturn:(UITextField *)textField forName:(NSString *)name;

@end

@interface CurrencyProxy :NSObject <UITextFieldDelegate>{
    id<CurrencyProxyListener> target;
    NSString *name;
}
@property (readonly) NSString *name;

-(id)initWithUser:(NSString*)aName andTarget:(id<CurrencyProxyListener>)aTarget;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string ;

@end
