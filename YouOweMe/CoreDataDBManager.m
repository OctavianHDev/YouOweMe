//
//  CoreDataDBManager.m
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "CoreDataDBManager.h"
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

#pragma mark create entities
-(Person *)createPersonWithAttributes:(NSDictionary *)attributes{
    return [Person personWithAttributes:attributes inManagedObjectContext:self.context];
}






#pragma mark - SETUP -

-(void)setDebtDatabase:(UIManagedDocument *)debtDatabase{
    _debtDatabase = debtDatabase;
    [self useDocument];
}


-(void)setup{
    if(!self.debtDatabase){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Debt Database"];
        self.debtDatabase = [[UIManagedDocument alloc]initWithFileURL:url];
    }
}


-(void)setupContextAndBroadcastContextIsNotNil{
    self.context = self.debtDatabase.managedObjectContext;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTEXT_IS_NOT_NIL"
                                                        object:nil];
}


-(void)useDocument{
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

@end
