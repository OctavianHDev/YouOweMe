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
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@end


@implementation HomeViewController


#pragma mark - getters/setters/synthesizers

CGRect predictiveSearchResultsOriginalFrame;

@synthesize gestureRecognitionView, predictiveSearchResults;
@synthesize inputView;
@synthesize predictiveSearchDataSource=_predictiveSearchDataSource;
@synthesize overlayView;
@synthesize personDetailView;
@synthesize debtAddingView;
@synthesize keyboardHeight;

-(PersonPredictiveSearchModel*)predictiveSearchDataSource{
    if(!_predictiveSearchDataSource)
        _predictiveSearchDataSource = [[PersonPredictiveSearchModel alloc]
                                       initWithSourcesFacebook:((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingFacebook
                                       andAddress:((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingAddressBook];
    return _predictiveSearchDataSource;
}




#pragma mark - instance vars

UIPanGestureRecognizer *panGestureRecognizer;


- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
  
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
}





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
    [self growPredictiveSearch];

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






#pragma mark - Keyboard

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    NSLog(@"Updating constraints.");
    // Because the "space" is actually the difference between the bottom lines of the 2 views,
    // we need to set a negative constant value here.
    self.keyboardHeight.constant = height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.keyboardHeight.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
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

-(void)shrinkPredictiveSearch{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.predictiveSearchResults
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:216]];

    /*if(predictiveSearchResultsOriginalFrame.size.height){
        [UIView animateWithDuration:0.2 animations:^{
            self.predictiveSearchResults.frame =  predictiveSearchResultsOriginalFrame;
        } completion:^(BOOL finished) {
            NSLog(@"shrink: pred results height set to: %f", predictiveSearchResultsOriginalFrame.size.height);
        }];
    }*/
}

-(void)textFieldGainedFocus{
    [self shrinkPredictiveSearch];
}

-(void)growPredictiveSearch{
    
    /*[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.predictiveSearchResults
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    /*[self.predictiveSearchResults addConstraint:
     [NSLayoutConstraint constraintWithItem:self.predictiveSearchResults attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:1]];
    /*CGRect frm = self.predictiveSearchResults.frame;
    predictiveSearchResultsOriginalFrame = frm;
    if(frm.size.height!= (self.view.bounds.size.height - self.inputView.frame.size.height)){
        [UIView animateWithDuration:0.2 animations:^{
            self.predictiveSearchResults.frame = CGRectMake(self.predictiveSearchResults.frame.origin.x,
                                                            self.predictiveSearchResults.frame.origin.y,
                                                            self.predictiveSearchResults.frame.size.width,
                                                            self.view.bounds.size.height - self.inputView.frame.size.height);
        } completion:^(BOOL finished) {
            NSLog(@"grow: pred results height set to: %f", self.view.bounds.size.height - self.inputView.frame.size.height);
        }];
    }*/
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

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];

    
    
    //login button
    //PrototypeAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    //[appDelegate openSessionWithAllowLoginUI:YES];
    /*if(FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded){
        NSLog(@"we're stil logged in");
    }else{
        NSLog(@"facebook session state: %u", FBSession.activeSession.state);
        FBLoginView *loginview = [[FBLoginView alloc] init];
        loginview.frame = CGRectOffset(loginview.frame, 5, 5);
        loginview.delegate = self;
        [self.view addSubview:loginview];
        [loginview sizeToFit];
    }*/
    
    [self observeKeyboard];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
