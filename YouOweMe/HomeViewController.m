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
#import "PersonPredictiveSearchModel.h"

@interface HomeViewController ()
    @property (nonatomic, strong) PersonPredictiveSearchModel *predictiveSearchDataSource;
@end


@implementation HomeViewController


#pragma mark - getters/setters/synthesizers

@synthesize gestureRecognitionView, predictiveSearchResults;
@synthesize inputView;
@synthesize predictiveSearchDataSource=_predictiveSearchDataSource;

-(PersonPredictiveSearchModel*)predictiveSearchDataSource{
    if(!_predictiveSearchDataSource)
        _predictiveSearchDataSource = [[PersonPredictiveSearchModel alloc] initWithSourcesFacebook:NO andAddress:YES];
    return _predictiveSearchDataSource;
}





#pragma mark - instance vars

UIPanGestureRecognizer *panGestureRecognizer;




#pragma mark - UITableView delegate



#pragma mark - DebtorNameTextInput delegate

-(void)textChangedTo:(NSString *)text{
    self.predictiveSearchResults.hidden=NO;
}

-(void)cancelPressed{
    [self hideInputView];
}




#pragma mark - gesture handlers

BOOL labelIsDown=NO;
BOOL isAnimating=NO;

-(void)handlePan:(UIPanGestureRecognizer*)gesture{
    
    
    if([gesture state] == UIGestureRecognizerStateChanged){
        //NSLog(@"deletmeInt: %d", deletemeInt);
    }
    
    if([gesture state] != UIGestureRecognizerStateEnded){
        CGPoint velocity = [gesture velocityInView:[gesture view]];
        
        //move the view to the top of the visible screen
        if(velocity.y>0 && !labelIsDown && !isAnimating){
            self.inputView.frame = CGRectOffset(self.inputView.frame, 0, velocity.y/80);
            if(CGRectIntersectsRect(inputView.bounds, self.view.frame)){
                [self showInputView];
            }
        }
        
        //move the view up above the screen
        if(velocity.y<0 && labelIsDown && !isAnimating ){
            [self hideInputView];
        }
    }
}





#pragma mark - moving the input view

-(void)showInputView{
    labelIsDown=YES;
    isAnimating=YES;
    //actionTakenForGesture=YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.inputView.frame = CGRectMake(0, 0, self.inputView.frame.size.width, self.inputView.frame.size.height);
    } completion:^(BOOL finished) {
        isAnimating=NO;
    }];
}

-(void)hideInputView{
    self.predictiveSearchResults.hidden=YES;
    labelIsDown=NO;
    isAnimating=YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.inputView.frame = CGRectMake(0, -60, self.inputView.frame.size.width, self.inputView.frame.size.height);
        [((DebtorNameTextInputView*)self.inputView) resetVisualComponents];
    } completion:^(BOOL finished) {
        isAnimating=NO;
    }];
}





#pragma mark - view lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //gesture
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.gestureRecognitionView addGestureRecognizer:panGestureRecognizer];
    
    //text input view
    self.inputView = [[DebtorNameTextInputView alloc] initWithFrame:CGRectMake(0, -60, self.view.bounds.size.width, 57)];
    ((DebtorNameTextInputView*)self.inputView).delegate = self;
    [self.view addSubview:self.inputView];
    
    //predictive search
    self.predictiveSearchResults.dataSource = self.predictiveSearchDataSource;
    self.predictiveSearchResults.delegate=self.predictiveSearchDataSource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
