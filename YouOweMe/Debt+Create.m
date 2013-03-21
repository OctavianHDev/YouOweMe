//
//  Debt+Create.m
//  YouOweMe
//
//  Created by o on 13-03-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "Debt+Create.h"

@implementation Debt (Create)

+(Debt*)debtForPerson:(Person *)p
             ofAmount:(NSNumber *)amount
      withDescription:(NSString*)description
inManagedObjectContext:(NSManagedObjectContext*)context{
    if(!p){
        NSLog(@"error: trying to insert debt, but no person provided");
        return nil;
    }
    if(!amount){
        NSLog(@"error: trying to insert debt, but no amount provided");
        return nil;
    }
    
    Debt *debt = [NSEntityDescription insertNewObjectForEntityForName:@"Debt" inManagedObjectContext:context];
    debt.paidOff = [NSNumber numberWithBool:NO];
    debt.amount = amount;
    debt.date = [NSDate date];
    debt.personOwing = p;
    debt.personOwedTo = nil;
    if(description || [description length]<1){
        debt.debtDescription = description;
    }else{
        debt.debtDescription = @"";
    }
    
    return debt;
}

@end
