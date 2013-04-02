//
//  PersonPredictiveSearchModel.h
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Person.h"

@protocol PredictiveSearchDelegate <NSObject>
    -(void)didSelectPerson:(UIView*)personCell;
    -(void)addDebtForPerson:(Person*)person;
    -(void)addPaymentForPerson:(Person*)person;
@end

@interface PersonPredictiveSearchModel : NSObject  <UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    FBLoginViewDelegate>

@property (nonatomic, strong) NSString *inputString;
@property (nonatomic, weak) id<PredictiveSearchDelegate> delegate;

-(id)initWithSourcesFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn;
-(void)refreshSourcesWithFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn;
-(void)setAsDataSourceAndDelegateFor:(UITableView*)tableView;
-(void)refreshTable;
@end
