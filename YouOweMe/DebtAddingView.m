//
//  DebtAddingView.m
//  YouOweMe
//
//  Created by o on 13-03-12.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "DebtAddingView.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreDataDBManager.h"

#define MOVED_ENOUGH 40

@interface DebtAddingView()

    @property CGPoint startTouchPoint;
    @property BOOL shouldDismissSelf;
    @property (nonatomic, strong) IBOutlet UIImageView *personAvatar;
    @property (nonatomic, strong) IBOutlet UILabel *personFirstName;
    @property (nonatomic, strong) IBOutlet UILabel *personlastName;
    @property (nonatomic, strong) IBOutlet UITextField *txtFieldAmount;
    @property (nonatomic, strong) IBOutlet UITextField *txtFieldDescription;

@end

@implementation DebtAddingView

@synthesize person= _person;
@synthesize personAvatar;
@synthesize personFirstName;
@synthesize personlastName;
@synthesize txtFieldAmount;
@synthesize txtFieldDescription;
@synthesize delegate;

@synthesize startTouchPoint, shouldDismissSelf;


#pragma mark - PUBLIC API
#pragma mark -

-(void)setPerson:(Person *)person{
    _person = person;
    self.personFirstName.text = person.firstName;
    self.personlastName.text = person.lastName;
    if(person.avatar.length<2)
        [self.personAvatar setImage:[UIImage imageNamed:@"default-user-image.png"]];
    else
        [self.personAvatar setImage:[UIImage imageWithData:person.avatar]];
    
    CALayer *imageLayer = self.personAvatar.layer;
    //[imageLayer setCornerRadius:4];
    [imageLayer setCornerRadius:self.personAvatar.frame.size.height/2];
    [imageLayer setMasksToBounds:YES];

}

-(Person*)person{
    return _person;
}

-(IBAction)donePressed:(id)sender{
    NSLog(@"here");
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *amount = [f numberFromString:self.txtFieldAmount.text];
    if(amount){
        NSString *desc = self.txtFieldDescription.text;
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
#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DebtAddingView" owner:self options:nil];
        self = [nib objectAtIndex:0];
        self.frame = frame;
        [self setup];
    }
    return self;
}

-(void)setup{
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 4.0f;
    self.layer.shadowOpacity = 0.8f;
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
            self.frame = CGRectMake(-2*self.frame.size.width,self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.delegate dissmissView:self andRefreshDebts:NO];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
        }];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    
    CGFloat touchDx;
    CGPoint touchPoint = [touch locationInView:[self superview]];
    touchDx = touchPoint.x - self.startTouchPoint.x;
    
    //NSLog(@"touchDx: %f", touchDx);
    
    if(touchDx<MOVED_ENOUGH*-1){
        self.shouldDismissSelf=YES;
    }else{
        self.shouldDismissSelf=NO;
    }
    
    if(touchDx<0)
        self.frame = CGRectMake(touchDx, self.frame.origin.y, self.frame.size.width, self.frame.size.height);

    [super touchesMoved:touches withEvent:event];
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
