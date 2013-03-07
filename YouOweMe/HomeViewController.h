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

@interface HomeViewController : UIViewController   <DebtorNameTextInputDelegate, PredictiveSearchDelegate>

@property (nonatomic, strong) IBOutlet UIView *gestureRecognitionView;
@property (nonatomic, strong) IBOutlet UITableView *predictiveSearchResults;
@property (nonatomic, strong) UIView *inputView;

-(IBAction)showPicker:(id)sender;

@end
