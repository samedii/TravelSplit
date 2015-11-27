//
//  InputProxy.h
//  splitter
//
//  Created by Richard Hermanson on 20/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InputProxyListener <NSObject>

- (void) filledInput:(UITextField *)sender forName: (id)name;

-(BOOL)textFieldShouldReturn:(UITextField *) textField forName: (id)name;

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string forName:(NSString *)name;

@end

@interface InputProxy : NSObject <UITextFieldDelegate> {
    
    id<InputProxyListener> target;
    NSString *name;
    
}
@property (readonly) NSString *name;

-(id)initWithUser:(NSString*)aName andTarget:(id<InputProxyListener>)aTarget;

@end
