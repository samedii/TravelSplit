//
//  IconPickerViewController.h
//  splitter
//
//  Created by Richard Hermanson on 09/11/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconProxy.h"

@interface IconPickerViewController : UIViewController <IconProxyListener> {
    
    NSDictionary *icons;
    
    NSArray *proxies;
    
    id listener;
    
    NSString *pickedIcon;
    NSString *pickedIconLabel;
    
}

@property (readonly) NSString *pickedIcon, *pickedIconLabel;

-(id)initWithListener:(id)aListener;

@end
