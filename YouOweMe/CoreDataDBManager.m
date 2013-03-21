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

-(Person *)personWithAttributes:(NSDictionary *)attributes fromSource:(NSString*)source{
    Person *toReturn;
    toReturn = [Person personWithAttributes:attributes fromSource:source inManagedObjectContext:self.context];
    return toReturn;
}

-(Person *)getPersonWithId:(NSString*)uniqueId inSource:(NSString*)source{
    Person *toReturn = [Person personWithId:uniqueId fromSource:source inManagedObjectContext:self.context];
    return toReturn;
}

-(NSArray*)getPersonsWithPredicate:(NSPredicate*)predicate{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    for(Person *p in results){
        NSLog(@"%@ pic is of size: %d, fbID: %@", p.firstName, [p.avatar length], p.facebookId);
    }
    return results;
}

-(void)insertIntoDBPersonsPicture:(UIImage*)picture ForId:(NSString*)personId fromSource:(NSString*)source{
    NSPredicate *predicate;
    if([source isEqualToString:SOURCE_ADDRESSBOOK]){
        predicate = [NSPredicate predicateWithFormat:@"addressBookId = %@", personId];
    }else if([source isEqualToString:SOURCE_FACEBOOK]){
        predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", personId];
    }
    NSArray *results = [self getPersonsWithPredicate:predicate];
    if(results.count>1){
        NSLog(@"error, trying to save picture, and more than one result came back for person w/ id: %@", personId);
    }else if(results.count<1){
        NSLog(@"error, trying to save picture, no results came back from db for person w/ id: %@", personId);
    }else{
        Person *p = [results objectAtIndex:0];
        p.avatar = UIImagePNGRepresentation(picture);
    }
}

@end
