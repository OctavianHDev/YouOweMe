//
//  PredictiveSearchResult.h
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonPredictiveSearchModel.h"
#import "Person.h"

@interface PredictiveSearchResult : UITableViewCell


@property (nonatomic, weak) id<PredictiveSearchDelegate> delegate;
@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) NSString *uniqueIdSource;

-(void)setAsMiniMode;
-(void)setAsSelected;
-(void)animateSliderHintWithDelay:(CGFloat)delayTime;

@end
