//
//  LatestDebtsDataSource.h
//  YouOweMe
//
//  Created by o on 13-03-28.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LatestDebtsDataSource : NSObject <UITableViewDataSource,
                                             UITableViewDelegate>

-(void)setAsUsingFacebook:(BOOL)facebookOn andAddressBook:(BOOL)addressBookOn;

@end
