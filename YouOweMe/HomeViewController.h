//
//  HomeViewController.h
//  YouOweMe
//
//  Created by o on 13-02-02.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DebtorNameInputCellView.h"

@interface HomeViewController : UIViewController   <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIView *dummyView;
@property (nonatomic, strong) IBOutlet UILabel *dummyLabel;
@property (nonatomic, strong) IBOutlet UIView *inputView;
-(IBAction)resetPressed:(id)sender;
-(IBAction)showPicker:(id)sender;

@end
