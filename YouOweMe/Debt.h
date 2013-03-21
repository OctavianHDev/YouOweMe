//
//  Debt.h
//  YouOweMe
//
//  Created by o on 13-03-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Debt : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * paidOff;
@property (nonatomic, retain) NSString * debtDescription;
@property (nonatomic, retain) Person *personOwedTo;
@property (nonatomic, retain) Person *personOwing;

@end
