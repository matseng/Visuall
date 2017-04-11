//
//  UserUtil.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/17/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
#import "StateUtilFirebase.h"

@interface UserUtil : NSObject

@property FIRUser *firebaseUser;

@property NSString *userID;

@property BOOL autoSignInIndicator;

+(id) sharedManager;

- (void) userIsSignedInHandler: (FIRUser *) firebaseUser;  // Implemented in StateUtil+Firebase.m

- (void) GIDdisconnect;

- (StateUtilFirebase *) getState;

//- (void) setAutoSignInIndicator: (BOOL) yesOrNo;

@end
