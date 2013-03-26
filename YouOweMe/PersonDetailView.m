//
//  PersonDetailView.m
//  YouOweMe
//
//  Created by o on 13-03-06.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "PersonDetailView.h"
#import <QuartzCore/QuartzCore.h>
#import "Person.h"
#import "CoreDataDBManager.h"

#define MOVED_ENOUGH 40



@interface PersonDetailView()
    @property (nonatomic, strong) Person* person;
    @property (nonatomic, strong) IBOutlet UIButton *btnDone;
    @property (nonatomic, strong) IBOutlet UIImageView *txtBkg1;
    @property (nonatomic, strong) IBOutlet UIImageView *txtBkg2;
    @property (nonatomic, strong) IBOutlet UITextField *txtFieldDebt;
    @property (nonatomic, strong) IBOutlet UITextField *txtFeidlDescription;

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
@synthesize btnDone,txtBkg1,txtBkg2,txtFeidlDescription,txtFieldDebt;
@synthesize shouldDismissSelf,startTouchPoint;

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

-(void)fadeInControls{
    self.txtBkg1.alpha=0;
    self.txtFieldDebt.alpha=0;
    self.btnDone.alpha=0;
    [UIView animateWithDuration:0.3 delay:0.2 options:nil animations:^{
        //self.txtBkg1.alpha=1;
        self.txtFieldDebt.alpha=1;
        self.btnDone.alpha=1;
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)setAsDebtAddingMode{
    self.isInDebtMode=YES;
    self.txtBkg1.hidden=NO;
    self.txtFieldDebt.hidden=NO;
    self.btnDone.hidden=NO;
    
    [self fadeInControls];
}

-(void)setAsDebtViewingMode{
    self.isInDebtMode=NO;
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
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(self.firstOrigin.x,
                                    self.firstOrigin.y,
                                    self.frame.size.width,
                                    self.frame.size.height);
        } completion:^(BOOL finished) {
            [self.delegate animatedViewToOriginalPosition];
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
    
    //NSLog(@"touchDx: %f", touchDx);
    
    if(touchDy<MOVED_ENOUGH*-1){
        self.shouldDismissSelf=YES;
    }else{
        self.shouldDismissSelf=NO;
    }
    
    if(touchDy<0){
        self.frame = CGRectMake(self.frame.origin.x,
                                touchDy,
                                self.frame.size.width,
                                self.frame.size.height);
    }
    [self.delegate draggingViewByDelta:[NSNumber numberWithFloat:touchDy]];
    [super touchesMoved:touches withEvent:event];
}






#pragma mark - ACTIONS
#pragma mark -
-(IBAction)donePressed:(id)sender{
    NSLog(@"here");
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *amount = [f numberFromString:self.txtFieldDebt.text];
    if(amount){
        NSString *desc = self.txtFeidlDescription.text;
        if(!desc || desc.length<1){
            desc = @"";
        }
        [[CoreDataDBManager initAndRetrieveSharedInstance]insertDebtForPerson:self.person ofAmount:amount withDescription:desc];
        [self.delegate dissmissView:self andRefreshDebts:YES];
        
    }else{
        //TODO: alert the user of invalid input
    }
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
