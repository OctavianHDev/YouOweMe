//
//  PredictiveSearchResult.m
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "PredictiveSearchResult.h"
#import "CoreDataDBManager.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"


#define MOVE_THRESHOLD 200.0
#define INDENTATION_AMOUNT 40.0
#define ALPHA_FOR_SELECTION 0.8


@interface PredictiveSearchResult()
    @property (nonatomic, strong) IBOutlet UILabel *lblName;
    @property (nonatomic, strong) IBOutlet UILabel *lblDebtOwing;
    @property (nonatomic, strong) IBOutlet UIImageView *avatar;
    @property (nonatomic, strong) IBOutlet UIImageView *imgViewBackgroundImage;
    @property (nonatomic, strong) NSString *name;
    @property (nonatomic, strong) NSString *uniqueId;
@end

@implementation PredictiveSearchResult

@synthesize lblName;
@synthesize name=_name;
@synthesize avatar;
@synthesize imgViewBackgroundImage;
@synthesize uniqueId;
@synthesize uniqueIdSource;
@synthesize delegate;
@synthesize person=_person;
@synthesize lblDebtOwing;

//ivars
CGPoint startTouchPoint;
UIView *bkgViewRightSwipeIndicator;
UIView *bkgViewLeftSwipeIndicator;
BOOL isShowingOverlayView;
BOOL isLongTouching=FALSE;
//used for gesturepanrecognizer method
//int firstX;
//int firstY;


#pragma mark - PUBLIC API
#pragma mark -
-(void)setAsMiniMode{
    self.lblDebtOwing.hidden=YES;
}

#pragma mark - moving

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	//NSLog(@"*touches began");
    UITouch *touch = [touches anyObject];
    startTouchPoint = [touch locationInView:self];

    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RightSwipeIndicator" owner:self options:nil];
    bkgViewRightSwipeIndicator = [nib objectAtIndex:0];
    bkgViewRightSwipeIndicator.frame = self.bounds;
    //bkgViewRightSwipeIndicator = [[UIView alloc] initWithFrame:self.bounds];
    bkgViewRightSwipeIndicator.backgroundColor = [UIColor redColor];
    bkgViewRightSwipeIndicator.alpha = 0;
    bkgViewRightSwipeIndicator.clipsToBounds = NO;
    bkgViewRightSwipeIndicator.layer.shadowColor = [[UIColor blackColor] CGColor];
    bkgViewRightSwipeIndicator.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    bkgViewRightSwipeIndicator.layer.shadowRadius = 2.0f;
    
    NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"LeftSwipeIndicator" owner:self options:nil];
    bkgViewLeftSwipeIndicator = [nib2 objectAtIndex:0];
    bkgViewLeftSwipeIndicator.frame = self.bounds;
    //bkgViewLeftSwipeIndicator = [[UIView alloc] initWithFrame:self.bounds];
    bkgViewLeftSwipeIndicator.backgroundColor = [UIColor greenColor];
    bkgViewLeftSwipeIndicator.alpha = 0;

    [self addSubview:bkgViewLeftSwipeIndicator];
    [self addSubview:bkgViewRightSwipeIndicator];
    
    isShowingOverlayView = NO;
    
    isLongTouching = YES;
    
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"*touches cancelled");
    [self maybeBringUpDebtView];
    isLongTouching=NO;
    [super touchesCancelled:touches withEvent:event];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"*touches ended");
    [self maybeBringUpDebtView];
    isLongTouching=NO;
    [super touchesEnded:touches withEvent:event];
}

-(void)maybeBringUpDebtView{

    if(bkgViewLeftSwipeIndicator.alpha>ALPHA_FOR_SELECTION){
        [UIView beginAnimations:nil context:NULL];
        
        [UIView commitAnimations];
    }
    
    //if(movedEnoughToRight){
    if(bkgViewRightSwipeIndicator.alpha>ALPHA_FOR_SELECTION && !isShowingOverlayView){
        isShowingOverlayView = YES;
        [UIView beginAnimations:nil context:NULL];
        /*[self.delegate addDebtForPerson:
            [[CoreDataDBManager initAndRetrieveSharedInstance] getPersonWithId:self.uniqueId inSource:self.uniqueIdSource]
        ];*/
        [self.delegate addDebtForPerson:self.person];
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
        
        /*bkgViewLeftSwipeIndicator.frame = CGRectMake(
                                                     bkgViewLeftSwipeIndicator.frame.origin.x,
                                                     bkgViewLeftSwipeIndicator.frame.origin.y-touchDx,
                                                     bkgViewLeftSwipeIndicator.frame.size.width,
                                                     bkgViewLeftSwipeIndicator.frame.size.height+touchDx*2);
        NSLog(@"changing y: %f", bkgViewLeftSwipeIndicator.frame.origin.y-touchDx);
        NSLog(@"changing height: %f", bkgViewLeftSwipeIndicator.frame.size.height+touchDx*2);
        */
        
        //NSLog(@"newAlpha (for right swipe): %f", newAlpha);
        bkgViewRightSwipeIndicator.alpha = newAlpha;
        if(newAlpha>=1){
            [self maybeBringUpDebtView];
            [self touchesCancelled:nil withEvent:nil];
        }
    }
    
    if(touchDx<0 && bkgViewRightSwipeIndicator.alpha<0.1){
        float newAlpha = MIN(touchDx,200)/-200.0f;
        //NSLog(@"newAlpha (for left swipe): %f", newAlpha);
        bkgViewLeftSwipeIndicator.alpha = newAlpha;
    }
    
    [super touchesMoved:touches withEvent:event];
}

#pragma mark - long press gestureRecognizer
-(void)handleLongPress:(UIGestureRecognizer*)sender{
    NSLog(@"LONG PRESS!");
    if(isLongTouching){
        //[self.delegate didSelectPerson:self.person];
        [self.delegate didSelectPerson:self];
        isLongTouching=NO;
    }
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
    //NSLog(@"just set name to: %@", name);
    self.lblName.text=name;    
}

-(NSString*)name{
    return _name;
}

-(void)setPerson:(Person *)person{
    _person = person;

    
    //NAME
    //
    self.name=[[person.firstName stringByAppendingString:@" "] stringByAppendingString:person.lastName];

    
    //IMAGE
    //
    if(person.avatar.length>2)
        [self.avatar setImage:[UIImage imageWithData:person.avatar]];
    else{
        
        //addressbook
        [self.avatar setImage:[UIImage imageNamed:@"default-user-image.png"]];

        //facebook
        if([self.uniqueIdSource isEqualToString:SOURCE_FACEBOOK]){
            NSString *strurl = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",person.facebookId];
            
            dispatch_queue_t downloadImageQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadImageQueue, ^{
                NSURL * imgURL = [NSURL URLWithString:strurl];
                NSData *imageData = [NSData dataWithContentsOfURL:imgURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *retrievedImage= [UIImage imageWithData:imageData];
                    self.avatar.alpha=0;
                    [self.avatar setImage:retrievedImage];
                    [UIView animateWithDuration:0.15 animations:^{
                        self.avatar.alpha=1;
                    }];
                    [[CoreDataDBManager initAndRetrieveSharedInstance] insertIntoDBPersonsPicture:retrievedImage ForId:person.facebookId fromSource:SOURCE_FACEBOOK];
                });
            });
        }
    }
    CALayer *imageLayer = self.avatar.layer;
    [imageLayer setCornerRadius:self.avatar.frame.size.height/2];
    //[imageLayer setCornerRadius:4];
    [imageLayer setMasksToBounds:YES];
    
    
    //DEBT
    //
    if(person.debts.count>0){
        float totalAmount = 0;
        for(Debt *d in person.debts){
            totalAmount += [d.amount floatValue];
        }
        //NSLog(@"total debt amount: %f", totalAmount);
        self.lblDebtOwing.text = [CURRENCY_SYMBOL stringByAppendingString:[NSString stringWithFormat:@"%.2f", totalAmount]];
        self.lblDebtOwing.hidden=NO;
    }else{
        self.lblDebtOwing.hidden=YES;
    }
    
    
    //SOURCE
    //
    if([self.uniqueIdSource isEqualToString:SOURCE_ADDRESSBOOK])
        self.uniqueId = person.addressBookId;
    if([self.uniqueIdSource isEqualToString:SOURCE_FACEBOOK])
        self.uniqueId = person.facebookId;
}

-(Person*)person{
    return _person;
}



#pragma mark - SETUP
#pragma mark -

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PredictiveSearchResult" owner:self options:nil];
        self = [nib objectAtIndex:0];
        self.clipsToBounds = NO;
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:lpgr];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
