//
//  AppDelegate.h
//  Visuall_CoreData
//
//  Created by Michael Tseng MacBook on 11/20/15.
//  Copyright © 2015 MobileMakers. All rights reserved.
//
@import Firebase;

#import <GoogleSignIn/GoogleSignIn.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end