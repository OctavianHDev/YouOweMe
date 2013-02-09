//
//  DebtorNameInputCellView.m
//  YouOweMe
//
//  Created by o on 13-02-08.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "DebtorNameInputCellView.h"

@implementation DebtorNameInputCellView

@synthesize debtorNameTextInput;
@synthesize delegate;


#pragma mark - textView delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textField text is: %@", textField.text);
}



#pragma mark - view lifeCycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
