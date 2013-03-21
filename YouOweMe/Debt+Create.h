//
//  Debt+Create.h
//  YouOweMe
//
//  Created by o on 13-03-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "Debt.h"
#import "Person.h"

@interface Debt (Create)

+(Debt*) debtForPerson:(Person *)p
              ofAmount:(NSNumber *)amount
       withDescription:(NSString*)description
inManagedObjectContext:(NSManagedObjectContext*)context;

@end
