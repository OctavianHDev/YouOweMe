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

+ (id)initAndRetrieveSharedInstance;
-(NSManagedObjectContext*)getContext;
-(Person *)createPersonWithAttributes:(NSDictionary *)attributes;

@end
