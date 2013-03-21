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

@interface HomeViewController : UIViewController   <DebtorNameTextInputDelegate,
                                                    PredictiveSearchDelegate,
                                                    DebtAddingDelegate>

@property (nonatomic, strong) IBOutlet UIView *gestureRecognitionView;
@property (nonatomic, strong) IBOutlet UITableView *predictiveSearchResults;
@property (nonatomic, strong) DebtorNameTextInputView *inputView;

@end
