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

@interface HomeViewController : UIViewController   <UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    UIScrollViewDelegate,
                                                    DebtorNameInputCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableView *tableViewPredictiveSearchResults;

-(IBAction)resetPressed:(id)sender;
-(IBAction)showPicker:(id)sender;

@end
