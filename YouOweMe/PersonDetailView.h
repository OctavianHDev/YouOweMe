//
//  PersonDetailView.h
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PredictiveSearchResult.h"


@class PersonDetailView;

@protocol DebtAddingDelegate <NSObject>
    -(void)dissmissView:(PersonDetailView*)detailView andRefreshDebts:(BOOL)shouldRefresh;
    -(void)draggingViewByDelta:(NSNumber*)delta;
    -(void)animatedViewToOriginalPosition;
@end

@interface PersonDetailView : UIView

@property (nonatomic, strong) PredictiveSearchResult* cell;
@property (nonatomic, weak)id<DebtAddingDelegate> delegate;
@property (nonatomic) BOOL shouldAddDebtOnRelease;

-(IBAction)closePressed:(id)sender;
-(void)preapareForDismissal;
-(void)setAsDebtAddingMode;
-(void)setAsDebtViewingMode;
@end
