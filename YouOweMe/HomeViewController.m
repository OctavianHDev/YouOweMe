//
//  HomeViewController.m
//  YouOweMe
//
//  Created by o on 13-02-02.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "HomeViewController.h"
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController ()
@end


@implementation HomeViewController

@synthesize dummyView, dummyLabel;
@synthesize inputView;

UIPanGestureRecognizer *panGestureRecognizer;




#pragma mark - gesture handlers

BOOL labelIsDown=NO;
BOOL isAnimating=NO;
BOOL actionTakenForGesture=NO;
-(void)handlePan:(UIPanGestureRecognizer*)gesture{
    UIView *piece = [gesture view];
    
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        actionTakenForGesture=NO;
    }
    
    if([gesture state] == UIGestureRecognizerStateChanged){
        //NSLog(@"deletmeInt: %d", deletemeInt);
    }
    
    if([gesture state] != UIGestureRecognizerStateEnded){
        CGPoint velocity = [gesture velocityInView:[gesture view]];
        if(velocity.y>0 && !labelIsDown && !isAnimating && !actionTakenForGesture){
            self.dummyLabel.frame = CGRectOffset(self.dummyLabel.frame, 0, velocity.y/80);
            if(CGRectIntersectsRect(dummyLabel.bounds, self.view.frame)){
                NSLog(@"I can see youuu...");
                labelIsDown=YES;
                isAnimating=YES;
                //actionTakenForGesture=YES;
                [UIView animateWithDuration:0.2f animations:^{
                    self.dummyLabel.frame = CGRectMake(0, 0, self.dummyLabel.frame.size.width, self.dummyLabel.frame.size.height);
                } completion:^(BOOL finished) {
                    isAnimating=NO;
                }];
            }
        }
        if(velocity.y<0 && labelIsDown && !isAnimating && !actionTakenForGesture){
            labelIsDown=NO;
            isAnimating=YES;
            actionTakenForGesture=YES;
            [UIView animateWithDuration:0.2f animations:^{
                self.dummyLabel.frame = CGRectMake(0, -53, self.dummyLabel.frame.size.width, self.dummyLabel.frame.size.height);
            } completion:^(BOOL finished) {
                isAnimating=NO;
            }];
            
        }
        
    }
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}


#pragma mark - Address book stuff

- (IBAction)showPicker:(id)sender
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
        NSLog(@"ios 5 or older, address book access granted");
    }
    
    if (accessGranted) {
        // Do whatever you want here.
        NSLog(@"ios 6+, address book access granted");
    }
}




#pragma mark - view lifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.dummyView addGestureRecognizer:panGestureRecognizer];
    
    inputView.layer.shadowColor=[[UIColor blueColor] CGColor];
    inputView.layer.shadowOpacity=0.8f;
    inputView.layer.shadowRadius=5.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - delete me
-(void)resetPressed:(id)sender{
    
}

@end
