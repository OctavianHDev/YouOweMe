//
//  Person+Create.m
//  YouOweMe
//
//  Created by o on 13-03-01.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "Person+Create.h"

@implementation Person (Create)

+(Person*)personWithAttributes:(NSDictionary*)attributes
        inManagedObjectContext:(NSManagedObjectContext*)context{
    Person *person = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [attributes objectForKey:@""]];
    if(!person){

        person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];

        person.addressBookId =[attributes objectForKey:@"addressBookId"];
        person.avatar = [attributes objectForKey:@"avatar"];
        person.facebookId = [attributes objectForKey:@"facebookId"];
        person.firstName = [attributes objectForKey:@"firstName"];
        person.lastName = [attributes objectForKey:@"source"];
        person.lastName = [attributes objectForKey:@"lastName"];
        person.debts = [attributes objectForKey:@"debts"];

    }
    return person;
}

@end
