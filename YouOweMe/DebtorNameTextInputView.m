//
//  DebtorNameTextInputView.m
//  YouOweMe
//
//  Created by o on 13-02-09.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "DebtorNameTextInputView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DebtorNameTextInputView

@synthesize textField, delegate;

#pragma mark - public functions

-(void)resetVisualComponents{
    self.textField.text=@"";
    [self.textField resignFirstResponder];
}


#pragma mark - actions

- (IBAction)xPressed:(id)sender {
    [self.textField resignFirstResponder];
    NSLog(@"x pressed");
    [self.delegate cancelPressed];
}

-(void)textFieldDidChange:(id)sender{
    [self.delegate textChangedTo:self.textField.text];
}


#pragma mark - view lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DebtorNameTextInputView" owner:self options:nil];
        self = [nib objectAtIndex:0];
        self.frame = frame;
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        //[self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"DebtorNameTextInputView" owner:self options:nil] objectAtIndex:0]];
        NSLog(@"DebtorNameTextInputView.m: initWithCoder");
        [self setup];
    }
    return self;
}

-(void)setup{
    NSLog(@"DebtorNameTextInputView.m: setup");
    
    self.layer.shadowColor=[[UIColor blueColor] CGColor];
    self.layer.shadowOpacity=0.8f;
    self.layer.shadowRadius=5.0f;
   
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}



/*-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        //[self addSubview:[[NSBundle mainBundle] loadNibNamed:@"DebtorNameTextInputView" owner:self options:nil]];
        self.textField.layer.borderColor=[[UIColor redColor] CGColor];
        self.textField.layer.borderWidth=2;
    }
    return self;
}*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
