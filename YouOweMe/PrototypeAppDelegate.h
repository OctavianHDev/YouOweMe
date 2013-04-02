//
//  PrototypeAppDelegate.h
//  YouOweMe
//
//  Created by o on 13-02-02.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrototypeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//user default flags
@property (nonatomic) BOOL isUsingAddressBook;
@property (nonatomic) BOOL isUsingFacebook;
@property (nonatomic) BOOL isFirstTimeRunningApp;

//core data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


//public API

//facebook
extern NSString *const FBSessionStateChangedNotification;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

//coredata
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
