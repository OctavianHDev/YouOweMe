//
//  PersonDetailView.m
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "PersonDetailView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PersonDetailView


#pragma mark - actions

-(IBAction)closePressed:(id)sender{
    [self removeFromSuperview];
}






#pragma mark - SETUP
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PersonDetailView" owner:self options:nil];
        self = [nib objectAtIndex:0];
        self.frame = frame;
        [self setup];
    }
    return self;
}

-(void)setup{
    NSLog(@"DebtorNameTextInputView.m: setup");
    
    self.layer.shadowColor=[[UIColor blackColor] CGColor];
    self.layer.shadowOpacity=0.5f;
    self.layer.shadowRadius=4.0f;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
