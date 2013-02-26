//
//  PersonPredictiveSearchModel.h
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@protocol PredictiveSearchDelegate <NSObject>
    -(void)didSelectPerson:(Person*)person;
@end

@interface PersonPredictiveSearchModel : NSObject  <UITableViewDataSource,
                                                    UITableViewDelegate>

@property (nonatomic, strong) NSString *inputString;
@property (nonatomic, strong)id<PredictiveSearchDelegate> delegate;

-(id)initWithSourcesFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn;
-(void)setAsDataSourceAndDelegateFor:(UITableView*)tableView;

@end
