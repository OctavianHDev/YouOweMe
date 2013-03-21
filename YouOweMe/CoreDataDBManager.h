//
//  CoreDataDBManager.h
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person+Create.h"

@interface CoreDataDBManager : NSObject

@property (readonly) NSManagedObjectContext *context;

+ (id)initAndRetrieveSharedInstance;
-(void)saveDB;

-(Person *)personWithAttributes:(NSDictionary *)attributes fromSource:(NSString*)source;
-(Person *)getPersonWithId:(NSString*)uniqueId inSource:(NSString*)source;
-(NSArray*)getPersonsWithPredicate:(NSPredicate*)predicate;
-(void)insertIntoDBPersonsPicture:(UIImage*)picture ForId:(NSString*)personId fromSource:(NSString*)source;
@end
