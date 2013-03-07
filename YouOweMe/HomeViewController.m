//
//  HomeViewController.m
//  YouOweMe
//
//  Created by o on 13-02-02.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreDataDBManager.h"
#import "PersonDetailView.h"

@interface HomeViewController ()
    @property (nonatomic, strong) PersonPredictiveSearchModel *predictiveSearchDataSource;
    @property (nonatomic, strong) UIView *overlayView;
    @property (nonatomic, strong) PersonDetailView *personDetailView;
@end


@implementation HomeViewController


#pragma mark - getters/setters/synthesizers

@synthesize gestureRecognitionView, predictiveSearchResults;
@synthesize inputView;
@synthesize predictiveSearchDataSource=_predictiveSearchDataSource;
@synthesize overlayView;
@synthesize personDetailView;


-(PersonPredictiveSearchModel*)predictiveSearchDataSource{
    if(!_predictiveSearchDataSource)
        _predictiveSearchDataSource = [[PersonPredictiveSearchModel alloc] initWithSourcesFacebook:NO andAddress:YES];
    return _predictiveSearchDataSource;
}




#pragma mark - instance vars

UIPanGestureRecognizer *panGestureRecognizer;




#pragma mark - PredictiveSearchDelegate delegate

-(void)didSelectPerson:(Person*)person{
    [self hideInputView];
    NSLog(@"selected person: %@ %@", person.firstName, person.lastName);
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PersonDetailView"
                                                             owner:self
                                                           options:nil];
    UIView *cell = [topLevelObjects objectAtIndex:0];
    int calculatedHeight = cell.frame.size.height;
    int calculatedWidth = cell.frame.size.width;
    
    self.personDetailView = [[PersonDetailView alloc] initWithFrame:CGRectMake(20, 20, calculatedWidth, calculatedHeight)];
    self.personDetailView.lblName.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
    self.personDetailView.imgViewAvatar.image = [UIImage imageWithData:person.avatar];
    [self.view addSubview:self.personDetailView];
}




#pragma mark - DebtorNameTextInput delegate

-(void)textChangedTo:(NSString *)text{
    self.predictiveSearchResults.hidden=NO;
    self.predictiveSearchResults.userInteractionEnabled=YES;
    self.predictiveSearchDataSource.inputString = text;
    self.gestureRecognitionView.hidden=YES;
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
        if(self.gestureRecognitionView.hidden)
            self.gestureRecognitionView.hidden=NO;
    }];
}




#pragma mark - coredata setup

-(void)setupContextForMembersWithNotification:(NSNotification *)notice{
    [self.predictiveSearchDataSource setAsDataSourceAndDelegateFor:self.predictiveSearchResults];
    self.predictiveSearchDataSource.delegate = self;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"CONTEXT IS NOT NIL!!!");
    if(overlayView){
        [overlayView removeFromSuperview];
    }
}





#pragma mark - view lifeCycle

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

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
    //[self.view insertSubview:self.inputView aboveSubview:self.predictiveSearchResults];
    
    //predictive search
    //if the doc pointing to the database has not been instantiated yet start listening for when it gets instantiated
    //then setup the predictiveSearchDataSource (and any other members that need the context)
    if(![[CoreDataDBManager initAndRetrieveSharedInstance] getContext]){
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(setupContextForMembersWithNotification:)
        name:@"CONTEXT_IS_NOT_NIL" object:nil];
        NSLog(@"CONTEXT IS NIL, LISTENING FOR NOTIFCATION");
        
        //display overlay to freeze app, so as to prevent faulty input
        //
        //TODO: MAKE A BETTER OVERLAY
        //
        self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha=0.5;
        [self.view addSubview:overlayView];
    }else{
        [self setupContextForMembersWithNotification:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
