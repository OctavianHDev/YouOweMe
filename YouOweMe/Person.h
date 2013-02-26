//
//  Person.h
//  YouOweMe
//
//  Created by o on 13-02-26.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Debt;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * addressBookId;
@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *debts;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addDebtsObject:(Debt *)value;
- (void)removeDebtsObject:(Debt *)value;
- (void)addDebts:(NSSet *)values;
- (void)removeDebts:(NSSet *)values;

@end
