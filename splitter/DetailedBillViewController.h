//
//  DetailedBillViewController.h
//  splitter
//
//  Created by Richard Hermanson on 21/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"

@protocol DetailedBillViewListener <NSObject>

-(Bill*)newImage:(UIImage*)image toBill:(Bill*)aBill;

-(Bill*)newTitle:(NSString*)title toBill:(Bill*)aBill ;

-(Bill*)newDesc:(NSString*)desc toBill:(Bill*)aBill ;

-(void)removeBill:(Bill*)bill;

@end

@interface DetailedBillViewController : UIViewController <UITextFieldDelegate,UINavigationControllerDelegate,UITextViewDelegate, UIImagePickerControllerDelegate> {
    id<DetailedBillViewListener> listener;
    Bill *bill;
    UITextView *descriptionTxtField;
    UITextField *titleField;
    UIButton *picture;
    UIButton *retakePicButton;
}

-(BOOL)textFieldDidBeginEditing:(UITextField *)textField;
-(id)initWithBill:(Bill*)aBill andListener:(id)aListener;

@end
