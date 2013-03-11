//
//  PredictiveSearchResult.m
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "PredictiveSearchResult.h"
#import "CoreDataDBManager.h"

#define MOVE_THRESHOLD 200.0
#define INDENTATION_AMOUNT 40.0
#define ALPHA_FOR_SELECTION 0.8
@implementation PredictiveSearchResult

@synthesize lblName;
@synthesize name=_name;
@synthesize avatar;
@synthesize imgViewBackgroundImage;
@synthesize uniqueId;
@synthesize uniqueIdSource;
@synthesize delegate;

//ivars
CGPoint startTouchPoint;
UIView *bkgViewRightSwipeIndicator;
UIView *bkgViewLeftSwipeIndicator;
//used for gesturepanrecognizer method
//int firstX;
//int firstY;


#pragma mark - moving

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"*touches began");
    UITouch *touch = [touches anyObject];
    startTouchPoint = [touch locationInView:self];

    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RightSwipeIndicator" owner:self options:nil];
    bkgViewRightSwipeIndicator = [nib objectAtIndex:0];
    bkgViewRightSwipeIndicator.frame = self.bounds;
    //bkgViewRightSwipeIndicator = [[UIView alloc] initWithFrame:self.bounds];
    bkgViewRightSwipeIndicator.backgroundColor = [UIColor redColor];
    bkgViewRightSwipeIndicator.alpha = 0;
    
    
    NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"LeftSwipeIndicator" owner:self options:nil];
    bkgViewLeftSwipeIndicator = [nib2 objectAtIndex:0];
    bkgViewLeftSwipeIndicator.frame = self.bounds;
    //bkgViewLeftSwipeIndicator = [[UIView alloc] initWithFrame:self.bounds];
    bkgViewLeftSwipeIndicator.backgroundColor = [UIColor greenColor];
    bkgViewLeftSwipeIndicator.alpha = 0;

    [self addSubview:bkgViewLeftSwipeIndicator];
    [self addSubview:bkgViewRightSwipeIndicator];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"*touches cancelled");
    [self maybeBringUpDebtView];
    [super touchesCancelled:touches withEvent:event];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"*touches ended");
    [self maybeBringUpDebtView];
    [super touchesEnded:touches withEvent:event];
}

-(void)maybeBringUpDebtView{

    if(bkgViewLeftSwipeIndicator.alpha>ALPHA_FOR_SELECTION){
        [UIView beginAnimations:nil context:NULL];
        
        [UIView commitAnimations];
    }
    
    //if(movedEnoughToRight){
    if(bkgViewRightSwipeIndicator.alpha>ALPHA_FOR_SELECTION){
        [UIView beginAnimations:nil context:NULL];
        [self.delegate addDebtForPerson:
            [[CoreDataDBManager initAndRetrieveSharedInstance] getPersonWithId:self.uniqueId inSource:self.uniqueIdSource]
        ];
        [UIView commitAnimations];
    }
    
    
    [UIView animateWithDuration:0.2 animations:^{
        bkgViewRightSwipeIndicator.alpha=0;
        bkgViewLeftSwipeIndicator.alpha=0;
    } completion:^(BOOL finished) {
        if(!finished)
            NSLog(@"error in animation");
        [bkgViewRightSwipeIndicator removeFromSuperview];
        [bkgViewLeftSwipeIndicator removeFromSuperview];
    }];

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];

    CGFloat touchDx;
    CGPoint touchPoint = [touch locationInView:[self superview]];
    touchDx = touchPoint.x - startTouchPoint.x;
    
    if(touchDx>20){
        self.exclusiveTouch=YES;
    }else{
        self.exclusiveTouch=NO;
    }
    
    if(touchDx>0 && bkgViewLeftSwipeIndicator.alpha<0.1){
        float newAlpha = MIN(touchDx,200)/200.0f;
        NSLog(@"newAlpha (for right swipe): %f", newAlpha);
        bkgViewRightSwipeIndicator.alpha = newAlpha;
    }
    
    if(touchDx<0 && bkgViewRightSwipeIndicator.alpha<0.1){
        float newAlpha = MIN(touchDx,200)/-200.0f;
        NSLog(@"newAlpha (for left swipe): %f", newAlpha);
        bkgViewLeftSwipeIndicator.alpha = newAlpha;
    }
    
    [super touchesMoved:touches withEvent:event];
}


#pragma mark - panning for gestureRecognizer
/*
-(void)handlePan:(UIGestureRecognizer *)sender{
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
   
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY);
    
    [[sender view] setCenter:translatedPoint];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {

        //pan to the left
        if([sender view].frame.origin.x>MOVE_THRESHOLD){
            [UIView animateWithDuration:0.12f animations:^{
                [sender view].frame = CGRectMake(MOVE_THRESHOLD,
                                                 sender.view.frame.origin.y,
                                                 sender.view.frame.size.width,
                                                 sender.view.frame.size.height);
            }];
        }
        
        //return to center
        if([sender view].frame.origin.x<MOVE_THRESHOLD &&
           [sender view].frame.origin.x>MOVE_THRESHOLD*-1){
            [UIView animateWithDuration:0.12f animations:^{
                [sender view].frame = CGRectMake(0,
                                                 sender.view.frame.origin.y,
                                                 sender.view.frame.size.width,
                                                 sender.view.frame.size.height);
            }];
        }
        
        //pan to the right
        if([sender view].frame.origin.x<MOVE_THRESHOLD*-1){
            [UIView animateWithDuration:0.12f animations:^{
                [sender view].frame = CGRectMake(MOVE_THRESHOLD*-1,
                                                 sender.view.frame.origin.y,
                                                 sender.view.frame.size.width,
                                                 sender.view.frame.size.height);
            }];
        }
        
    }
    //following code "throws" the view around according to the velocity of the pan(swipe, really, at this point)
    //
    /*if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        CGFloat velocityX = (0.2*[(UIPanGestureRecognizer*)sender velocityInView:self].x);
        
        
        CGFloat finalX = translatedPoint.x + velocityX;
        //CGFloat finalY = firstY;// translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
        
        CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;
        
        NSLog(@"the duration is: %f", animationDuration);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
        [[sender view] setCenter:CGPointMake(finalX, firstY)];
        [UIView commitAnimations];
    }
}*/

#pragma mark - setters/getters

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
