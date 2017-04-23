//
//  StateUtilFirebase+Create.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/22/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import "StateUtilFirebase+Create.h"
#import "UserUtil.h"

@implementation StateUtilFirebase (Create)

+ (void) setSharedVisuall: (NSString *) visuallKey withEmails: (NSArray *) emails
{
//    NSString *userID = [[UserUtil sharedManager] userID];
    FIRDatabaseReference *version01TableRef = [[[FIRDatabase database] reference] child:@"version_01"];
    FIRDatabaseReference *sharedVisuallInvites = [version01TableRef child: @"shared-visuall-invites"];
    FIRDatabaseReference *emailRef;
    for (NSString *email in emails)
    {
        emailRef = [sharedVisuallInvites child: email];
        NSDictionary *dict = @{visuallKey: @1};
        [emailRef updateChildValues:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            NSLog(@"\n setSharedVisuall invited %@:", dict);
        }];
    }
    
    
    //    FIRDatabaseReference *usersTableCurrentUser = [[version01TableRef child:@"users"] child: userID];
    //    FIRDatabaseReference *visuallsPersonalRef =  [usersTableCurrentUser child: @"visualls-personal"];
    //    FIRDatabaseReference *visuallsTableRef = [version01TableRef child: @"visualls"];
    //    FIRDatabaseReference *currentVisuallRef = [visuallsTableRef childByAutoId];
    //    //    FIRDatabaseReference *currentVisuallMetatdataRef = [currentVisuallRef child: @"metadata"];
    //
    //    NSDictionary *visuallDictionary = @{
    //                                        @"date-created": [FIRServerValue timestamp],
    //                                        @"created-by": [FIRAuth auth].currentUser.uid,
    //                                        @"created-by-first-name": [[[[GIDSignIn sharedInstance] currentUser] profile] givenName],
    //                                        @"created-by-last-name": [[[[GIDSignIn sharedInstance] currentUser] profile] familyName],
    //                                        @"created-by-email": [[[[GIDSignIn sharedInstance] currentUser] profile] email],
    //                                        @"write-permission" : @{ [FIRAuth auth].currentUser.uid : @"1" }
    //                                        };
    //    [metadata setValuesForKeysWithDictionary: visuallDictionary];
    //    NSMutableDictionary *dict = [@{@"metadata": metadata,
    //                                   @"write-permission" : @{ [FIRAuth auth].currentUser.uid : @"1" }} mutableCopy];
    //    [currentVisuallRef updateChildValues: dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
    //     {
    //         [visuallsPersonalRef updateChildValues: @{currentVisuallRef.key: @"1"} ];
    //     }];
    //    [metadata setObject: currentVisuallRef.key forKey:@"key"];
    //    return metadata;
}
@end
