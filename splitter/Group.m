//
//  Group.m
//  splitter
//
//  Created by Richard Hermanson on 20/12/11.
//  Copyright 2011 Direwolf. All rights reserved.
//

#import "Group.h"


@implementation Group

-(id)init {
    self = [super init];
    if(self) {
        //get from harddrive
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        //users = [prefs arrayForKey:@"bills"]; //returns nil if no array found
        
        NSData *encodedUsers = [prefs objectForKey:@"users"];
        users = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:encodedUsers];
        
        if(users == NULL) {
            
            users = [NSArray arrayWithObjects:nil];
            
        }
        
        [users retain];
    }
    return self;
}

-(void)addUser:(NSString*)aUser
{
    if([users containsObject:aUser]) {
        return;
    }
    
    NSArray *newUsers;
    if(users)
    {
        newUsers = [users arrayByAddingObject:aUser];
        [users release];
    }
    else
        newUsers = [NSArray arrayWithObject:aUser];
    
    users  = newUsers;
    [users retain];
    
    [Group _saveUsers:users];
}



+(void)_saveUsers:(NSArray*)someUsers
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedUsers = [NSKeyedArchiver archivedDataWithRootObject:someUsers];
    
    [prefs setObject:encodedUsers forKey:@"users"];
    
    [prefs synchronize];
}

-(NSArray*)getUsers {
    return [NSArray arrayWithArray:users];
}

-(void)dealloc {
    [users release];
    [super dealloc];
}

-(void)deleteUser:(NSString *)aUser{
    
    //Note: Checks should be implemented earlier to check if user cannot be deleted due to existance in bills

    if(![users containsObject:aUser]) {
        NSLog(@"Warning: Tried to delete non-existent user");
        return;
    }
    
    NSArray *newUsers;

    NSMutableArray *mutable = [NSMutableArray arrayWithArray:users];
    [mutable removeObject:aUser];
        
    newUsers = [NSArray arrayWithArray:mutable];
    [users release];
    
    users  = newUsers;
    [users retain];
    
    [Group _saveUsers:users];
    
}

-(void)removeAllUsers {
    [users release];
    users = [NSArray arrayWithObjects:nil];
    [users retain];
    
    [Group _saveUsers:users];
}

@end
