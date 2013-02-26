//
//  PredictiveSearchResult.m
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "PredictiveSearchResult.h"

@implementation PredictiveSearchResult

@synthesize lblName;
@synthesize name=_name;
@synthesize avatar;

-(void)setName:(NSString *)name{
    _name=name;
    NSLog(@"just set name to: %@", name);
    self.lblName.text=name;
}

-(NSString*)name{
    return _name;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PredictiveSearchResult" owner:self options:nil];
        self = [nib objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
