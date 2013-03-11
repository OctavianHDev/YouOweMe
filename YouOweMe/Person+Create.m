//
//  Person+Create.m
//  YouOweMe
//
//  Created by o on 13-03-01.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "Person+Create.h"
#import "Constants.h"

@implementation Person (Create)

+(Person*)personWithAttributes:(NSDictionary*)attributes
        inManagedObjectContext:(NSManagedObjectContext*)context{
    Person *person = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"addressBookId = %@", [attributes objectForKey:@"addressBookId"]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count>1){
        NSLog(@"!matches || matches.count>1");
    }else if(![matches count]){
        person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
        
        person.addressBookId =[attributes objectForKey:@"addressBookId"];
        person.avatar = [attributes objectForKey:@"avatar"];
        person.facebookId = [attributes objectForKey:@"facebookId"];
        person.firstName = [attributes objectForKey:@"firstName"];
        person.source = [attributes objectForKey:@"source"];
        person.lastName = [attributes objectForKey:@"lastName"];
        person.debts = [attributes objectForKey:@"debts"];

    }else{
        person = [matches lastObject];
    }
    return person;
}

+(Person*)personFromId:(NSString*)uniqueId andSource:(NSString*)source inManagedObjectContext:(NSManagedObjectContext*)context{
    Person *person = nil;
    if([source isEqualToString:SOURCE_ADDRESSBOOK]){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
        request.predicate = [NSPredicate predicateWithFormat:@"addressBookId = %@", uniqueId];
        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if(!matches || matches.count>1){
            NSLog(@"!matches || matches.count>1");
        }else if(![matches count]){
            NSLog(@"no matches found");
        }else{
            person = [matches lastObject];
        }
        
    }
    
    return person;
}

@end
