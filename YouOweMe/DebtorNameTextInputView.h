//
//  DebtorNameTextInputView.h
//  YouOweMe
//
//  Created by o on 13-02-09.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DebtorNameTextInputDelegate <NSObject>

    -(void)textChangedTo:(NSString*)text;
    -(void)cancelPressed;
    -(void)textFieldGainedFocus;
@end



@interface DebtorNameTextInputView : UIView <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, weak) id<DebtorNameTextInputDelegate>delegate;

-(void)resetVisualComponents;

@end
