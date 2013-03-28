//
//  HUDhint.m
//  YouOweMe
//
//  Created by o on 13-03-26.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "HUDhint.h"
#import <QuartzCore/QuartzCore.h>

@implementation HUDhint

@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HUDhint" owner:self options:nil];
        self = [nib objectAtIndex:0];
        self.frame = frame;
        [self setup];
    }
    return self;
}

-(void)setup{
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 6.0f;
    //self.layer.cornerRadius = 4;
    self.layer.opaque = YES;
    self.label.textColor = [UIColor colorWithRed:232.0f/255.0 green:232/255.0 blue:232/255.0 alpha:1.0f];
    self.opaque=YES;
    self.backgroundColor = [UIColor clearColor];
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
