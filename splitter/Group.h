//
//  Group.h
//  splitter
//
//  Created by Richard Hermanson on 20/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Group : NSObject {
    NSArray *users;
}
-(void)addUser:(NSString*)aUser;
-(NSArray*)getUsers;
-(void)removeAllUsers;

-(void)deleteUser:(NSString*)aUser;

//Local
+(void)_saveUsers:(NSArray*)someUsers;
@end
