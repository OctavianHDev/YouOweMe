//
//  DebtorNameInputCellView.h
//  YouOweMe
//
//  Created by o on 13-02-08.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DebtorNameInputCellDelegate <NSObject>
    -(void)inputHasChangedTo:(NSString*)newInput;
@end

@interface DebtorNameInputCellView : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *debtorNameTextInput;
@property (nonatomic, weak) id<DebtorNameInputCellDelegate>delegate;

@end
