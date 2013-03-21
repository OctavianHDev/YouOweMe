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

+(Person*)personWithAttributes:(NSDictionary*)attributes fromSource:(NSString *)source
        inManagedObjectContext:(NSManagedObjectContext*)context{
    Person *person = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    if([source isEqualToString:SOURCE_ADDRESSBOOK]){
        request.predicate = [NSPredicate predicateWithFormat:@"addressBookId = %@", [attributes objectForKey:@"addressBookId"]];
    }else if ([source isEqualToString:SOURCE_FACEBOOK]){
        request.predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", [attributes objectForKey:@"facebookId"]];
    }
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if([[attributes objectForKey:@"firstName"] isEqualToString:@"Alina"]){
        NSLog(@"here");
    }
    
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

        NSLog(@"inserted %@ %@ with fb id:%@", person.firstName, person.lastName, person.facebookId);
    }else{
        person = [matches lastObject];
    }
    return person;
}

+(Person*)personWithId:(NSString*)uniqueId fromSource:(NSString*)source
inManagedObjectContext:(NSManagedObjectContext*)context{
    Person *person = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    if([source isEqualToString:SOURCE_ADDRESSBOOK]){
        request.predicate = [NSPredicate predicateWithFormat:@"addressBookId = %@", uniqueId];
    }else if([source isEqualToString:SOURCE_FACEBOOK]){
        request.predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", uniqueId];
    }
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count>1){
        if(error)
            NSLog(@"error: %@", [error description]);
        NSLog(@"matches error or more than one match returned");
    }else if(![matches count]){
        NSLog(@"error, record %@ in %@ not found!!", uniqueId, source);
    }else{
        person = [matches lastObject];
    }
    
    return person;
}



@end
