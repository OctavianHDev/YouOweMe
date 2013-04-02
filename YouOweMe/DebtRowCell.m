//
//  DebtRowCell.m
//  YouOweMe
//
//  Created by o on 13-03-28.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "DebtRowCell.h"
#import "Constants.h"

@interface DebtRowCell()
    @property (nonatomic, strong) IBOutlet UILabel *debtAmount;
@end

@implementation DebtRowCell

@synthesize debt = _debt;
@synthesize debtAmount;


#pragma mark - getters/setters
#pragma mark -
-(Debt*)debt{
    return _debt;
}

-(void)setDebt:(Debt *)debt{
    _debt=debt;
    self.debtAmount.text = [NSString stringWithFormat:@"%@%.2f", CURRENCY_SYMBOL,[debt.amount floatValue]];
}






#pragma mark - setup
#pragma mark -
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
