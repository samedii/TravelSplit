//
//  SpecialProxy.h
//  splitter
//
//  Created by Richard Hermanson on 07/04/12.
//  Copyright 2012 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SpecialProxyListener <NSObject>

-(void)toggleEditFor:(NSString*)user;

@end

@interface SpecialProxy : NSObject {
    id<SpecialProxyListener> target;
    NSString *name;
    BOOL activated;
}

@property (readonly) NSString *name;
@property (assign) BOOL activated;

-(id)initWithUser:(NSString*)aName andTarget:(id<SpecialProxyListener>)aTarget;

@end
