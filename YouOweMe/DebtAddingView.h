//
//  DebtAddingView.h
//  YouOweMe
//
//  Created by o on 13-03-12.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@class DebtAddingView;

@protocol DebtAddingDelegate <NSObject>
    -(void)dissmissView:(DebtAddingView*)debtAddingView andRefreshDebts:(BOOL)shouldRefresh;
@end


@interface DebtAddingView : UIView

@property (nonatomic, strong) Person* person;
@property (nonatomic, weak)id<DebtAddingDelegate> delegate;

-(IBAction)donePressed:(id)sender;

@end
