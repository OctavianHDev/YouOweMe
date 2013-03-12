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
#import "PrototypeAppDelegate.h"
#import "DebtAddingView.h"

@interface HomeViewController ()
    @property (nonatomic, strong) PersonPredictiveSearchModel *predictiveSearchDataSource;
    @property (nonatomic, strong) UIView *overlayView;
    @property (nonatomic, strong) PersonDetailView *personDetailView;
    @property (nonatomic, strong) DebtAddingView *debtAddingView;
@end


@implementation HomeViewController


#pragma mark - getters/setters/synthesizers

@synthesize gestureRecognitionView, predictiveSearchResults;
@synthesize inputView;
@synthesize predictiveSearchDataSource=_predictiveSearchDataSource;
@synthesize overlayView;
@synthesize personDetailView;
@synthesize debtAddingView;

-(PersonPredictiveSearchModel*)predictiveSearchDataSource{
    if(!_predictiveSearchDataSource)
        _predictiveSearchDataSource = [[PersonPredictiveSearchModel alloc]
                                       initWithSourcesFacebook:((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingFacebook
                                       andAddress:((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingAddressBook];
    return _predictiveSearchDataSource;
}




#pragma mark - instance vars

UIPanGestureRecognizer *panGestureRecognizer;




#pragma mark - PredictiveSearchDelegate DELEGATE
#pragma mark -

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

-(void)addPaymentForPerson:(Person *)person{}

-(void)addDebtForPerson:(Person *)person{
    NSLog(@"adding debt for: %@", person.firstName);

    [self.inputView.textField resignFirstResponder];

    /*//add overlay
    self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha=0.5;
    UITapGestureRecognizer *tapr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOverlayTap:)];
    [self.overlayView addGestureRecognizer:tapr];
    [self.view addSubview:self.overlayView];
    */
    
    //add HUD
    /*NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DebtAddingView" owner:self options:nil];
    UIView *dummy = [nib objectAtIndex:0];
    float hudWidth = dummy.frame.size.width;
    float hudHeight = dummy.frame.size.height;
    */
    float hudWidth = 300;
    self.debtAddingView= [[DebtAddingView alloc] initWithFrame:CGRectMake(hudWidth*-1,
                                                                         0,
                                                                         hudWidth, self.view.frame.size.height)];
    self.debtAddingView.person=person;
    [self.view addSubview:self.debtAddingView];
    [UIView animateWithDuration:0.2 animations:^{
        self.debtAddingView.frame = CGRectMake(0,
                                               0,
                                               self.view.frame.size.width, self.view.frame.size.height);
    }];
}

/*
-(void)handleOverlayTap:(UITapGestureRecognizer *)sender{
    [UIView animateWithDuration:0.3 animations:^{
        self.overlayView.alpha=0.0f;
        self.debtAddingView.frame = CGRectMake(-1000,
                                               self.debtAddingView.frame.origin.y,
                                               self.debtAddingView.frame.size.width,
                                               self.debtAddingView.frame.size.height);
    } completion:^(BOOL finished) {
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
        
        [self.debtAddingView removeFromSuperview];
        self.debtAddingView = nil;
    }];
}*/



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




#pragma mark - view lifeCycle

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        
    //gesture to swipe in text input for predictive search
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.gestureRecognitionView addGestureRecognizer:panGestureRecognizer];
    
    //text input view for predictive search
    self.inputView = [[DebtorNameTextInputView alloc] initWithFrame:CGRectMake(0, -60, self.view.bounds.size.width, 57)];
    ((DebtorNameTextInputView*)self.inputView).delegate = self;
    [self.view addSubview:self.inputView];

    
    //predictive search
    //if the doc pointing to the database has not been instantiated yet start listening for when it gets instantiated
    //then setup the predictiveSearchDataSource (and any other members that need the context)
    if(![[CoreDataDBManager initAndRetrieveSharedInstance] context]){
        //TODO: better error handling here
        NSLog(@"ERROR, context is nil! BAD!");
    }else{
        [self.predictiveSearchDataSource setAsDataSourceAndDelegateFor:self.predictiveSearchResults];
        self.predictiveSearchDataSource.delegate = self;
        NSLog(@"CONTEXT IS NOT NIL!!!");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
