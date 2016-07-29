//
//  ViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/4/15.
//  Copyright (c) 2015 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Firebase/Firebase.h>
#import "GroupItem.h"
#import "NotesCollection.h"
#import "GroupsCollection.h"

@import Firebase;
//@import FirebaseDatabase;

#import <GoogleSignIn/GoogleSignIn.h>

@interface ViewController : UIViewController <GIDSignInUIDelegate>

@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;

@property (nonatomic, strong) NSString *firebaseURL;

@property (strong, nonatomic) IBOutlet UIView *Background;

@property (strong, nonatomic) IBOutlet UIScrollView *BackgroundScrollView;

@property (strong, nonatomic) IBOutlet UIView *VisualItemsView;

@property (strong, nonatomic) IBOutlet UIView *GroupsView;

@property (strong, nonatomic) IBOutlet UIView *ArrowsView;

@property UIView *drawGroupView;

@property (strong, nonatomic) IBOutlet UIView *NotesView;

@property (strong, nonatomic) UIScrollView *scrollViewButtonList;

@property NotesCollection *NotesCollection;

@property GroupsCollection *groupsCollection;

@property UIView *lastSelectedObject;

@property UIView *activelySelectedObjectDuringPan;

- (BOOL) setSelectedObject:(UIView *) object;

- (void) backButtonHandler;

- (void) buttonTapped: (id) sender;

- (void) drawGroup: (UIPanGestureRecognizer *) gestureRecognizer;

//- (void) updateChildValue: (id) visualObject andProperty: (NSString *) propertyName;

//- (void) updateChildValues: (id) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2;

- (void) setTransformFirebase;

- (void) setInitialNote: (NoteItem2 *) ni;

- (void) addNoteToViewWithHandlers:(NoteItem2 *) noteItem;

- (void) removeValue: (id) object;

@end

