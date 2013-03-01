//
//  Person+Create.h
//  YouOweMe
//
//  Created by o on 13-03-01.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "Person.h"

@interface Person (Create)

+(Person*)personWithAttributes:(NSDictionary*)attributes
        inManagedObjectContext:(NSManagedObjectContext*)context;

@end
