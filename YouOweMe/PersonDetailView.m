//
//  PersonDetailView.m
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "PersonDetailView.h"
#import "Person.h"
#import "CoreDataDBManager.h"
#import "HUDhint.h"
#import "DebtRowCell.h"

#define MOVED_ENOUGH 40
#define MSG_FOOTER @"SWIPE UP TO DISMISS"
#define CALCULATED_SELF_HEIGHT 173

@interface PersonDetailView()

    @property (nonatomic, strong) Person* person;

    //debt adding
    @property (nonatomic, strong) IBOutlet UIButton *btnDone;
    @property (nonatomic, strong) IBOutlet UIImageView *txtBkgDebt;
    @property (nonatomic, strong) IBOutlet UIImageView *txtBkgDescription;
    @property (nonatomic, strong) IBOutlet UITextField *txtFieldDebt;
    @property (nonatomic, strong) IBOutlet UITextField *txtFieldDescription;
    @property (nonatomic, strong) UIImageView *owesBanner;
    @property (nonatomic, strong) HUDhint *hudHint;
    @property (nonatomic, strong) IBOutlet UILabel *errorCorrectionLabel;
    @property (nonatomic, strong) IBOutlet UIImageView *errorCorrectionImage;

    //debt viewing
    @property (nonatomic, strong) IBOutlet UITableView *tableDebts;
    @property (nonatomic, strong) NSArray *sortedDebts;

    //moving
    @property CGPoint startTouchPoint;
    @property CGPoint firstOrigin;
    @property BOOL shouldDismissSelf;

    //flags
    @property (nonatomic) BOOL isInDebtMode;
@end

@implementation PersonDetailView

@synthesize cell=_cell;
@synthesize person;
@synthesize btnDone,txtBkgDebt,txtBkgDescription,txtFieldDescription,txtFieldDebt;
@synthesize shouldDismissSelf,startTouchPoint;
@synthesize owesBanner;
@synthesize shouldAddDebtOnRelease;
@synthesize hudHint;
@synthesize tableDebts;
@synthesize sortedDebts=_sortedDebts;


#pragma mark - getters/setters

-(NSArray *)sortedDebts{
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sorted = [self.person.debts sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
    _sortedDebts = sorted;
    return _sortedDebts;
}


-(void)setSortedDebts:(NSArray *)sortedDebts{
    _sortedDebts=sortedDebts;
}



#pragma mark - PUBLIC API
#pragma mark -
-(void)setCell:(PredictiveSearchResult *)cell{
    _cell = cell;
    self.person=cell.person;
    _cell.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [_cell setAsMiniMode];
    [self addSubview:_cell];
}

-(void)preapareForDismissal{
    [UIView animateWithDuration:0.1 animations:^{
        self.cell.frame = CGRectMake(self.cell.frame.origin.x,
                                     self.cell.frame.origin.y-20,
                                     self.cell.frame.size.width,
                                     self.cell.frame.size.height);
        self.cell.alpha=0;
    } completion:^(BOOL finished) {
        [self.cell removeFromSuperview];
    }];
}

-(void)fadeOutControls{
    [UIView animateWithDuration:0.3 delay:0.0 options:nil animations:^{

        self.txtFieldDebt.alpha=0;
        self.txtFieldDescription.alpha=0;
        self.hudHint.alpha=0;
        self.errorCorrectionImage.alpha=0;
        self.errorCorrectionLabel.alpha=0;

    } completion:^(BOOL finished) {
        
        //
        /*self.owesBanner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"owesBanner"]];
         self.owesBanner.contentMode = UIViewContentModeScaleAspectFill;
         self.owesBanner.frame = CGRectMake(0, 20, 80, 40);
         self.owesBanner.clipsToBounds=YES;
         [self addSubview:self.owesBanner];*/
        
    }];

}

-(void)fadeInControls{
    self.txtBkgDebt.alpha=0;
    self.txtFieldDebt.alpha=0;
    self.txtFieldDescription.alpha=0;

    CGRect hintFrame = CGRectMake(0,CALCULATED_SELF_HEIGHT+5, self.frame.size.width, 30);
    self.hudHint = [[HUDhint alloc]initWithFrame:hintFrame];
    self.hudHint.label.text = MSG_FOOTER;
    self.hudHint.alpha=0;
    [self addSubview:self.hudHint];

    //self.btnDone.alpha=0;
    [UIView animateWithDuration:0.3 delay:0.2 options:nil animations:^{
        //self.txtBkgDebt.alpha=1;
        self.txtFieldDebt.alpha=1;
        self.txtFieldDescription.alpha=1;
        self.hudHint.alpha=1;
        //self.btnDone.alpha=1;
    } completion:^(BOOL finished) {
        //
        /*self.owesBanner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"owesBanner"]];
        self.owesBanner.contentMode = UIViewContentModeScaleAspectFill;
        self.owesBanner.frame = CGRectMake(0, 20, 80, 40);
        self.owesBanner.clipsToBounds=YES;
        [self addSubview:self.owesBanner];*/

    }];
}

-(void)setAsDebtAddingMode{
    self.isInDebtMode=YES;
    self.txtBkgDebt.hidden=NO;
    self.txtFieldDebt.hidden=NO;
    self.txtFieldDescription.hidden=NO;
    self.tableDebts.hidden=YES;
    //self.btnDone.hidden=NO;
    
    [self fadeInControls];
}

-(void)setAsDebtViewingMode{
    self.isInDebtMode=NO;
    self.txtBkgDebt.hidden=YES;
    self.txtFieldDebt.hidden=YES;
    self.txtFieldDescription.hidden=YES;
    self.tableDebts.hidden=NO;
    self.tableDebts.dataSource = self;
}




#pragma mark - UITABLEVIEW DELEGATE
#pragma mark -

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"DebtCell";
    DebtRowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[DebtRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.debt = (Debt*)[self.sortedDebts objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.person.debts.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}




#pragma mark - MOVING
#pragma mark -
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"*touches began");
    UITouch *touch = [touches anyObject];
    self.startTouchPoint = [touch locationInView:self];
    
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"*touches cancelled");
    [self maybeDismissSelf];
    [super touchesCancelled:touches withEvent:event];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"*touches ended");
    [self maybeDismissSelf];
    [super touchesEnded:touches withEvent:event];
}

-(void)maybeDismissSelf{
    
    if(shouldDismissSelf){
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(self.firstOrigin.x,self.frame.size.width*-2, self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.delegate dissmissView:self andRefreshDebts:NO];
        }];
    
    //ok so we're not dismissing ourselves, meaning that either we weren't pulled up far enough,
    //or we were pulled down, in which case we're going to add the debt, if this view
    //was pulled down far enough
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(self.firstOrigin.x,
                                    self.firstOrigin.y,
                                    self.frame.size.width,
                                    self.frame.size.height);
        } completion:^(BOOL finished) {
            if(self.shouldAddDebtOnRelease){
                NSLog(@"adding that debt");
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *amount = [f numberFromString:self.txtFieldDebt.text];
                if(amount){
                    NSString *desc = self.txtFieldDescription.text;
                    if(!desc || desc.length<1){
                        desc = @"";
                    }
                    [[CoreDataDBManager initAndRetrieveSharedInstance]insertDebtForPerson:self.person ofAmount:amount withDescription:desc];
                    [self.delegate dissmissView:self andRefreshDebts:YES];
                
                    //TODO: have some animation indicating that the debt is added
                    //once that's completed, go ahead and...
                    [self fadeOutControls];

                //user didn't input a number for a debt. come on now
                }else{
                    self.errorCorrectionLabel.hidden=NO;
                    self.errorCorrectionImage.hidden=NO;
                    
                    [UIView animateWithDuration:0.4 delay:3.0 options:nil animations:^{
                        self.errorCorrectionLabel.alpha=0;
                        self.errorCorrectionImage.alpha=0;
                    } completion:^(BOOL finished) {
                        self.errorCorrectionImage.hidden=YES;
                        self.errorCorrectionLabel.hidden=YES;
                        self.errorCorrectionLabel.alpha=1;
                        self.errorCorrectionImage.alpha=1;
                    }];
                }

                //alert the parent view that we're animating to the original position
                //this is done so that the black overlay can animate smoothly to its original alpha
                [self.delegate animatedViewToOriginalPosition];

            }else{
                //alert the parent view that we're animating to the original position
                //this is done so that the black overlay can animate smoothly to its original alpha
                [self.delegate animatedViewToOriginalPosition];
            }
        }];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!self.isInDebtMode)
        return;
    UITouch *touch = [touches anyObject];
    
    CGFloat touchDy;
    CGPoint touchPoint = [touch locationInView:[self superview]];
    touchDy = touchPoint.y - self.startTouchPoint.y;
    
    //NSLog(@"touchDy: %f", touchDy);
    
    if(touchDy<MOVED_ENOUGH*-1){
        self.shouldDismissSelf=YES;
    }else{
        self.shouldDismissSelf=NO;
    }
    
    //if(touchDy<self.startTouchPoint.y){
        self.frame = CGRectMake(self.frame.origin.x,
                                touchDy,
                                self.frame.size.width,
                                self.frame.size.height);
   // }
    [self.delegate draggingViewByDelta:[NSNumber numberWithFloat:touchDy]];
    [super touchesMoved:touches withEvent:event];
}






#pragma mark - ACTIONS
#pragma mark -
-(IBAction)donePressed:(id)sender{
    NSLog(@"done pressed");
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
        self.firstOrigin = frame.origin;
        [self setup];
    }
    return self;
}

-(void)setup{
    NSLog(@"DebtorNameTextInputView.m: setup");
    
    self.layer.shadowColor=[[UIColor blackColor] CGColor];
    self.layer.shadowOpacity=0.3f;
    self.layer.shadowRadius=3.0f;
    
    self.txtFieldDebt.textColor = [UIColor darkGrayColor];
    self.txtFieldDescription.textColor = [UIColor darkGrayColor];
    [self.txtFieldDebt becomeFirstResponder];
    self.errorCorrectionImage.hidden=YES;
    self.errorCorrectionLabel.hidden=YES;
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
