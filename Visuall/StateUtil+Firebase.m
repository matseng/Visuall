//
//  StateUtil+FIrebase.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtil+Firebase.h"

@implementation StateUtil (Firebase)

FIRDatabaseReference *_ref;

-(void) userIsSignedInHandler: (FIRUser *) user
{
    _ref = [[[FIRDatabase database] reference] child:@"version_01"];
    NSString *userID = [FIRAuth auth].currentUser.uid;
    NSString *name;
    NSString *email;
    NSString *provider;
    for ( id <FIRUserInfo> profile in user.providerData) {
        NSString *providerID = profile.providerID;
        NSString *uid = profile.uid;  // Provider-specific UID
        name = profile.displayName;
        email = profile.email;
        //        provider = profile.email;
        NSURL *photoURL = profile.photoURL;
        NSLog(@"userID: %@", userID);
        NSLog(@"uid: %@", uid);
    }
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ( ![snapshot exists] )  // we have a new user
        {
            NSDictionary *newUserBasicUserInfo = @{
                                                   @"full_name" : name,
                                                   @"email": email,
                                                   @"date_joined": [FIRServerValue timestamp],
                                                   @"date_last_visit": [FIRServerValue timestamp]
                                                   };
            [[[_ref child:@"users"] child: userID] setValue: newUserBasicUserInfo];
        } else {
            NSLog(@"%@", snapshot.value );
            [[[_ref child:@"users"] child: userID] updateChildValues:@{@"date_last_visit": [FIRServerValue timestamp]}];
        }
        
        // Get user value
        //        NSString *myUserName = snapshot.value[@"username"];
        
        // ...
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

//- (void) setValueNote: (NoteItem2 *) ni
//{
//    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
//    Firebase *notesRef = [ref childByAppendingPath: @"notes2"];
//    Firebase *newNoteRef = [notesRef childByAutoId];
//    NSDictionary *noteDictionary = @{
//                                     @"data/title": ni.note.title,
//                                     @"data/x": [NSString stringWithFormat:@"%.3f", ni.note.x],
//                                     @"data/y": [NSString stringWithFormat:@"%.3f", ni.note.y],
//                                     @"style/font-size": [NSString stringWithFormat:@"%.3f", ni.note.fontSize]
//                                     };
//    [newNoteRef updateChildValues: noteDictionary];
//    ni.note.key = newNoteRef.key;
//}

@end
