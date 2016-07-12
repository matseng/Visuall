//
//  ViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/4/15.
//  Copyright (c) 2015 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "GroupItem.h"
#import "NotesCollection.h"
#import "GroupsCollection.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) NSString *firebaseURL;

@property (strong, nonatomic) IBOutlet UIView *Background;

@property (strong, nonatomic) UIScrollView *scrollViewButtonList;

@property NotesCollection *NotesCollection;

@property GroupsCollection *groupsCollection;

@property UIView *lastSelectedObject;

@property (weak, nonatomic) IBOutlet UIView *GroupsView;

@property UIView *drawGroupView;

@property (weak, nonatomic) IBOutlet UIView *NotesView;

- (BOOL) setSelectedObject:(UIView *) object;

- (void) backButtonHandler;

- (void) buttonTapped: (id) sender;

- (void) drawGroup: (UIPanGestureRecognizer *) gestureRecognizer;

//- (void) setItemsInGroup: (GroupItem *) groupItem;

- (void) updateChildValue: (id) visualObject andProperty: (NSString *) propertyName;

- (void) updateChildValues: (id) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2;

//- (void) handlePanGroup: (UIPanGestureRecognizer *) gestureRecognizer andGroupItem: (GroupItem *) groupItem;

//- (void) refreshG roupView;

- (void) setTransformFirebase;

@end

