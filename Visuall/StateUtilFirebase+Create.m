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
}
@end
