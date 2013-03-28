//
//  HomeViewController.h
//  YouOweMe
//
//  Created by o on 13-02-02.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DebtorNameTextInputView.h"
#import "PersonPredictiveSearchModel.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DebtAddingView.h"
#import "PersonDetailView.h"

@interface HomeViewController : UIViewController   <DebtorNameTextInputDelegate,
                                                    PredictiveSearchDelegate,
                                                    DebtAddingDelegate>

@end
