//
//  PersonPredictiveSearchModel.h
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonPredictiveSearchModel : NSObject  <UITableViewDataSource,
                                                    UITableViewDelegate>

-(id)initWithSourcesFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn;

@end
