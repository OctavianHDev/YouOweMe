//
//  CoreDataDBManager.m
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "CoreDataDBManager.h"
#import "Constants.h"

@interface CoreDataDBManager()

    @property CoreDataDBManager *sharedInstance;
    @property (nonatomic, strong) UIManagedDocument *debtDatabase;
    @property (nonatomic, strong) NSManagedObjectContext *context;

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
        [sharedInstance setup];
    });
    return sharedInstance;
}

-(NSManagedObjectContext*)getContext{
    return self.context;
}

//called from app delegate in applicationWillTerminate
//
-(void)saveDB{
    [self.debtDatabase saveToURL:self.debtDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if(success)
            NSLog(@"successfully saved db");
        else
            NSLog(@"error in trying to save db");
    }];
}


#pragma mark create entities

-(Person *)createPersonWithAttributes:(NSDictionary *)attributes{
    Person *toReturn = [Person personWithAttributes:attributes inManagedObjectContext:self.context];
    return toReturn;
}

-(Person *)getPersonWithId:(NSString*)uniqueId fromSource:(NSString *)source{
    Person *toReturn = [Person personFromId:uniqueId andSource:source inManagedObjectContext:self.context];
    return toReturn;
}


#pragma mark - PRIVATE API -
#pragma mark setup 

-(void)setup{
    if(!self.debtDatabase){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"DefaultDebtDatabase"];
        self.debtDatabase = [[UIManagedDocument alloc]initWithFileURL:url];
        NSLog(@"database's url: %@", [url description]);
    }
}


-(void)setDebtDatabase:(UIManagedDocument *)debtDatabase{
    _debtDatabase = debtDatabase;
    [self useDocument];
}


-(void)useDocument{
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:@"FULL" forKey:@"synchronous"];
    [pragmaOptions setObject:@"1" forKey:@"fullfsync"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             pragmaOptions, NSSQLitePragmasOption,
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    self.debtDatabase.persistentStoreOptions = options;
                             
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.debtDatabase.fileURL path]]){
        [self.debtDatabase saveToURL:self.debtDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupContextAndBroadcastContextIsNotNil];
        }];
    }else if (self.debtDatabase.documentState ==UIDocumentStateClosed){
        [self setupContextAndBroadcastContextIsNotNil];
    }else if (self.debtDatabase.documentState ==UIDocumentStateNormal){
        [self setupContextAndBroadcastContextIsNotNil];
    }
}


-(void)setupContextAndBroadcastContextIsNotNil{
    self.context = self.debtDatabase.managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTEXT_IS_NOT_NIL"
                                                        object:nil];
}

@end
