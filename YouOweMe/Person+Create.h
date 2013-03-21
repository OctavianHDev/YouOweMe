//
//  Person+Create.h
//  YouOweMe
//
//  Created by o on 13-03-01.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "Person.h"

@interface Person (Create)

+(Person*)personWithAttributes:(NSDictionary*)attributes fromSource:(NSString*)source inManagedObjectContext:(NSManagedObjectContext*)context;

+(Person*)personWithId:(NSString*)uniqueId fromSource:(NSString*)source
        inManagedObjectContext:(NSManagedObjectContext*)context;

@end
