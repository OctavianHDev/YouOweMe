//
//  CoreDataDBManager.m
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "CoreDataDBManager.h"
#import "Constants.h"
#import "PrototypeAppDelegate.h"

@interface CoreDataDBManager()

    @property CoreDataDBManager *sharedInstance;
    @property (nonatomic, strong) UIManagedDocument *debtDatabase;

@end

@implementation CoreDataDBManager

@synthesize sharedInstance;
@synthesize debtDatabase = _debtDatabase;
@synthesize context;

#pragma mark - PUBLIC API - 
#pragma mark -
+ (id)initAndRetrieveSharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSManagedObjectContext*)context{
    return ((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
}

//called from app delegate in applicationWillTerminate
//
-(void)saveDB{
    [((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
}


#pragma mark create entities

-(Person *)personWithAttributes:(NSDictionary *)attributes{
    Person *toReturn = [Person personWithAttributes:attributes inManagedObjectContext:self.context];
    return toReturn;
}

-(Person *)getPersonWithId:(NSString*)uniqueId inSource:(NSString*)source{
    Person *toReturn = [Person personWithId:uniqueId inSource:source inManagedObjectContext:self.context];
    return toReturn;
}

@end
