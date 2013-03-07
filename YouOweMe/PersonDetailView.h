//
//  PersonDetailView.h
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonDetailView : UIView

@property IBOutlet UILabel *lblName;
@property IBOutlet UIImageView *imgViewAvatar;
@property IBOutlet UIButton *btnClose;

-(IBAction)closePressed:(id)sender;

@end
