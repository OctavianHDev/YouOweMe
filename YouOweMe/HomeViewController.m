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
#import "PredictiveSearchResult.h"
#import "HUDhint.h"

#define OVERLAY_ALPHA 0.6
#define OVERLAY_BELOW_PREDICTIVESEARCH_ALPHA 0.8
#define MOVING_DOWN_THRESHOLD_FOR_ADDING_DEBT 68
#define DEBT_ADDING_VIEW_ORIGINAL_Y 34
#define DEBT_ADDING_VIEW_ORIGINAL_X 20
#define MSG_PULL_TO_ADD_DEBT @"PULL TO ADD DEBT"
#define MSG_RELEASE_TO_ADD_DEBT @"RELEASE TO ADD DEBT"

#define ICON_ALPHA_OFF 0.3

@interface HomeViewController ()

    @property (nonatomic, strong) IBOutlet UIView *gestureRecognitionView;
    @property (nonatomic, strong) IBOutlet UITableView *predictiveSearchResults;
    @property (nonatomic, strong) DebtorNameTextInputView *inputView;
    @property (nonatomic, strong) IBOutlet UISwitch *inputSourceSwitch;

    @property (nonatomic, strong) IBOutlet UIImageView *iconFB;
    @property (nonatomic, strong) IBOutlet UIImageView *iconAddressbook;
    @property (nonatomic, strong) IBOutlet UIView *overlayBelowPredictiveSearch;
    @property (nonatomic, strong) PersonPredictiveSearchModel *predictiveSearchDataSource;
    @property (nonatomic, strong) UIView *overlayView;
    @property (nonatomic, strong) PersonDetailView *personDetailView;

    @property (nonatomic, strong) HUDhint *hintView;
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
@synthesize iconAddressbook, iconFB;
@synthesize keyboardHeight;
@synthesize hintView;
@synthesize inputSourceSwitch;
@synthesize overlayBelowPredictiveSearch;


-(PersonPredictiveSearchModel*)predictiveSearchDataSource{
    if(!_predictiveSearchDataSource)
        _predictiveSearchDataSource = [[PersonPredictiveSearchModel alloc]
                                       initWithSourcesFacebook:((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingFacebook
                                       andAddress:((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingAddressBook];
    return _predictiveSearchDataSource;
}




#pragma mark - instance vars

UIPanGestureRecognizer *panGestureRecognizer;



#pragma mark - debt adding delegate
#pragma mark -

-(void)animatedViewToOriginalPosition{
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayView.alpha=OVERLAY_ALPHA;
    }];
    self.hintView.label.text = MSG_PULL_TO_ADD_DEBT;
}

-(void)draggingViewByDelta:(NSNumber*)delta{
    NSLog(@"delta is: %@", delta);
    float newAlpha = OVERLAY_ALPHA*100 + ([delta floatValue]*1.5);
    if(newAlpha<OVERLAY_ALPHA*100 && newAlpha>8)
        self.overlayView.alpha=newAlpha/100;
    //self.hintView.alpha = [delta floatValue]/100;
    if([delta floatValue]>MOVING_DOWN_THRESHOLD_FOR_ADDING_DEBT){
        self.hintView.label.text = MSG_RELEASE_TO_ADD_DEBT;
        self.personDetailView.shouldAddDebtOnRelease=YES;
    }else{
        self.hintView.label.text = MSG_PULL_TO_ADD_DEBT;
        self.personDetailView.shouldAddDebtOnRelease=NO;
    }
}


-(void)dissmissView:(PersonDetailView*)debtAddingView andRefreshDebts:(BOOL)shouldRefresh{
    if(shouldRefresh){
        [self.predictiveSearchDataSource refreshTable];
    }

    if(self.hintView){
        [self.hintView removeFromSuperview];
        self.hintView = nil;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.personDetailView.frame = CGRectMake(0,
                                               -300,
                                               self.view.frame.size.width, self.view.frame.size.height);
        self.overlayView.alpha=0.0;
    } completion:^(BOOL finished) {
        
        [self.personDetailView removeFromSuperview];
        self.personDetailView = nil;

        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
    }];
}



#pragma mark - PredictiveSearchDelegate DELEGATE
#pragma mark -

-(void)didSelectPerson:(UIView*)personCell{
    //DON'T DO THIS MORE THAN ONCE PER LONG PRESS
    if(self.personDetailView)
        return;
    
    //ADD DISMISS OVERLAY
    //
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha=0.0;
    UITapGestureRecognizer *tapr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOverlayTap:)];
    [self.overlayView addGestureRecognizer:tapr];
    [self.view addSubview:self.overlayView];
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayView.alpha=OVERLAY_ALPHA;
    }];
    
    Person *person = ((PredictiveSearchResult*)personCell).person;
    CGPoint originPoint = [personCell.superview convertPoint:personCell.frame.origin toView:self.view];
    //CGRect animatedViewFrame = [personCell.superview convertRect:personCell.frame toView:self.view];
    CGRect startingFrame = CGRectMake(originPoint.x, originPoint.y, personCell.frame.size.width, personCell.frame.size.height);
    PredictiveSearchResult *addedCell = [[PredictiveSearchResult alloc] initWithFrame:startingFrame];
    NSLog(@"adding at: %f",originPoint.y);
    addedCell.person = person;
    addedCell.userInteractionEnabled=NO;
    [self.view addSubview:addedCell];
    addedCell.frame=startingFrame;
    
    [UIView animateWithDuration:0.23 animations:^{
        
        addedCell.frame = CGRectMake(20,
                                     20,
                                     addedCell.frame.size.width-40,
                                     addedCell.frame.size.height-40);
        
    } completion:^(BOOL finished) {
        [addedCell removeFromSuperview];
        //ADD ACTUAL PERSON INFO
        //
        NSLog(@"selected person: %@ %@", person.firstName, person.lastName);
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PersonDetailView"
                                                                 owner:self
                                                               options:nil];
        UIView *cell = [topLevelObjects objectAtIndex:0];
        int calculatedHeight = cell.frame.size.height;
        int calculatedWidth = cell.frame.size.width;
        
        self.personDetailView = [[PersonDetailView alloc] initWithFrame:CGRectMake(20, 20, calculatedWidth, addedCell.frame.size.height)];
        self.personDetailView.cell = addedCell;
        [self.personDetailView setAsDebtViewingMode];
        
        //self.personDetailView.lblName.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
        //self.personDetailView.imgViewAvatar.image = [UIImage imageWithData:person.avatar];
        [self.view addSubview:self.personDetailView];
        [UIView animateWithDuration:0.25 animations:^{
            
            self.personDetailView.frame=CGRectMake(20, 20, calculatedWidth, calculatedHeight);
        }];
    }];
}


-(void)addDebtForPerson:(Person *)person{
    //DON'T DO THIS MORE THAN ONCE PER LONG PRESS
    if(self.personDetailView)
        return;
    
    //ADD DISMISS OVERLAY
    //
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha=0.0;
    UITapGestureRecognizer *tapr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOverlayTap:)];
    [self.overlayView addGestureRecognizer:tapr];
    [self.view addSubview:self.overlayView];
    [UIView animateWithDuration:0.2 animations:^{
        self.overlayView.alpha=OVERLAY_ALPHA;
    }];
    
    CGPoint originPoint = CGPointMake(DEBT_ADDING_VIEW_ORIGINAL_X, -30);
    NSArray *topLevelObjects1 = [[NSBundle mainBundle] loadNibNamed:@"PredictiveSearchResult"
                                                             owner:self
                                                           options:nil];
    UIView *cell = [topLevelObjects1 objectAtIndex:0];
    int calculatedHeight = cell.frame.size.height;
    int calculatedWidth = cell.frame.size.width;


    //MOVE USER CELL 
    CGRect startingFrame = CGRectMake(originPoint.x, -30, cell.frame.size.width, cell.frame.size.height);
    PredictiveSearchResult *addedCell = [[PredictiveSearchResult alloc] initWithFrame:startingFrame];
    addedCell.person = person;
    addedCell.userInteractionEnabled=NO;
    [addedCell setAsMiniMode];
    [self.view addSubview:addedCell];
    addedCell.frame=startingFrame;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        addedCell.frame = CGRectMake(DEBT_ADDING_VIEW_ORIGINAL_X,
                                     DEBT_ADDING_VIEW_ORIGINAL_Y,
                                     addedCell.frame.size.width-40,
                                     addedCell.frame.size.height-40);
        
    } completion:^(BOOL finished) {
        
        //remove the cell we just moved around; it'll be in the exact same spot as the cell
        //that will be added automatically by the personDetailView
        [addedCell removeFromSuperview];

        //ADD ACTUAL PERSON INFO
        //
        NSLog(@"selected person: %@ %@", person.firstName, person.lastName);
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PersonDetailView"
                                                                 owner:self
                                                               options:nil];
        UIView *cell = [topLevelObjects objectAtIndex:0];
        int calculatedHeight = cell.frame.size.height;
        int calculatedWidth = cell.frame.size.width;
        
        self.personDetailView = [[PersonDetailView alloc]
                                 initWithFrame:CGRectMake(
                                                          DEBT_ADDING_VIEW_ORIGINAL_X,
                                                          DEBT_ADDING_VIEW_ORIGINAL_Y,
                                                          calculatedWidth,
                                                          addedCell.frame.size.height
                                                          )
                                 ];
        self.personDetailView.cell = addedCell;
        self.personDetailView.delegate = self;
        [self.personDetailView setAsDebtAddingMode];
        
        [self.view addSubview:self.personDetailView];

        // ANIMATE THE DROP DOWN EFFECT
        [UIView animateWithDuration:0.25 animations:^{
            
            self.personDetailView.frame=CGRectMake(
                                                   DEBT_ADDING_VIEW_ORIGINAL_X,
                                                   DEBT_ADDING_VIEW_ORIGINAL_Y,
                                                   calculatedWidth,
                                                   calculatedHeight
                                                   );
            
        } completion:^(BOOL finished) {
            
            CGRect hintRect = CGRectMake(self.personDetailView.frame.origin.x,
                                         0,
                                         self.personDetailView.frame.size.width,
                                         30);
            
            self.hintView = [[HUDhint alloc] initWithFrame:hintRect];
            
            self.hintView.label.text = MSG_PULL_TO_ADD_DEBT;

            //((UILabel*)self.hintView).layer.shadowColor = [[UIColor blackColor] CGColor];
            //((UILabel*)self.hintView).layer.shadowRadius = 4.0f;
            //((UILabel*)self.hintView).backgroundColor = [UIColor clearColor];
            //[self.view addSubview:self.hintView];

            [self.view insertSubview:self.hintView belowSubview:self.personDetailView];
            //self.hintView.alpha=0;
            self.hintView.opaque=YES;
            
        }];
    }];

}


-(void)handleOverlayTap:(UITapGestureRecognizer *)sender{
    [self.personDetailView preapareForDismissal];
    [UIView animateWithDuration:0.15 delay:0.15 options:nil animations:^{
        
        self.overlayView.alpha=0.0f;
        self.personDetailView.alpha=0.0f;
        
        self.personDetailView.frame=CGRectMake(self.personDetailView.frame.origin.x+25,
                                               self.personDetailView.frame.origin.y+25,
                                               self.personDetailView.frame.size.width-50,
                                               self.personDetailView.frame.size.height-50);
        
    } completion:^(BOOL finished) {
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
        
        [self.personDetailView removeFromSuperview];
        self.personDetailView = nil;
        
        if(self.hintView){
            [self.hintView removeFromSuperview];
            self.hintView=nil;
        }
    }];
}


-(void)dismissTextInput:(id)sender{
    [self hideInputView];
}




#pragma mark - Keyboard

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect newFrame = CGRectMake(0, 57, self.view.frame.size.width, self.view.frame.size.height-216-57);

    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:animationDuration animations:^{
        self.predictiveSearchResults.frame = newFrame;
    }];
    
    /*NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    NSLog(@"Updating constraints to:%f",height);
    // Because the "space" is actually the difference between the bottom lines of the 2 views,
    // we need to set a negative constant value here.
    self.keyboardHeight.constant = height*-1;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];*/
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGRect newFrame = CGRectMake(0, 57, self.view.frame.size.width, self.view.frame.size.height-57);
  
    self.predictiveSearchResults.frame = newFrame;
    
    /*NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat height = 116;//(self.view.frame.size.height-57);
    self.keyboardHeight.constant = height*-1;
    NSLog(@"Updating constraints to:%f",height);

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // [self.predictiveSearchResults];
    }];*/
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

-(void)textFieldGainedFocus{
    //remove this
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
    self.overlayBelowPredictiveSearch.alpha=0;
    self.overlayBelowPredictiveSearch.hidden=NO;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.inputView.frame = CGRectMake(0, 0, self.inputView.frame.size.width, self.inputView.frame.size.height);
        self.overlayBelowPredictiveSearch.alpha=OVERLAY_BELOW_PREDICTIVESEARCH_ALPHA;
    } completion:^(BOOL finished) {
        isAnimating=NO;
        
        [self.predictiveSearchDataSource
         refreshSourcesWithFacebook:((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingFacebook
         andAddress:((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingAddressBook];
    }];
}

-(void)hideInputView{
    self.predictiveSearchResults.hidden=YES;
    labelIsDown=NO;
    isAnimating=YES;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.inputView.frame = CGRectMake(0, -60, self.inputView.frame.size.width, self.inputView.frame.size.height);
        [((DebtorNameTextInputView*)self.inputView) resetVisualComponents];
        self.overlayBelowPredictiveSearch.alpha=0;
    } completion:^(BOOL finished) {
        isAnimating=NO;
        if(self.gestureRecognitionView.hidden)
            self.gestureRecognitionView.hidden=NO;
        self.overlayBelowPredictiveSearch.hidden=YES;
    }];
}

#pragma mark - view lifeCycle

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //gesture to swipe in text input for predictive search
    //
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.gestureRecognitionView addGestureRecognizer:panGestureRecognizer];
    
    //text input view for predictive search
    //
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
    
    //set up the source swtich
    self.inputSourceSwitch.offImage = [UIImage imageNamed:@"textInputBkg.png"];
    self.inputSourceSwitch.onImage = [UIImage imageNamed:@"textInputBkg.png"];
    [self.inputSourceSwitch addTarget:self action:@selector(switchedSource:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *tapFb = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(selectIconFB:)];
    [self.iconFB addGestureRecognizer:tapFb];
    
    UITapGestureRecognizer *tapAddr = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(selectIconAddr:)];
    [self.iconAddressbook addGestureRecognizer:tapAddr];
    
    /*self.keyboardHeight =[NSLayoutConstraint constraintWithItem:self.predictiveSearchResults
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.view
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1
                                                       constant:0];
    [self.view addConstraint:self.keyboardHeight];
    */
    
    
    //overlay
    //
    self.overlayBelowPredictiveSearch.hidden=YES;
    self.overlayBelowPredictiveSearch.backgroundColor = [UIColor blackColor];
    self.overlayBelowPredictiveSearch.alpha=OVERLAY_ALPHA;
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTextInput:)];
    [self.overlayBelowPredictiveSearch addGestureRecognizer:t];
    
    [self observeKeyboard];
}


#pragma mark - SOURCE SWITCHER
#pragma mark -

//switcher
//
-(void)switchedSource:(id)sender{
    if(self.inputSourceSwitch.isOn){
        [self selectAddressBookAsSource];
    }else{
        [self selectFaceBookAsSource];
    }
}

//fb
//
-(void)selectIconFB:(id)sender{
    [self selectFaceBookAsSource];
    [self.inputSourceSwitch setOn:NO animated:YES];
}

-(void)selectFaceBookAsSource{
    self.iconFB.alpha=1;
    self.iconAddressbook.alpha = ICON_ALPHA_OFF;
    ((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingFacebook=YES;
    ((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingAddressBook=NO;
}

//addressbook
//
-(void)selectAddressBookAsSource{
    self.iconAddressbook.alpha=1;
    self.iconFB.alpha = ICON_ALPHA_OFF;
    ((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingFacebook=NO;
    ((PrototypeAppDelegate*)[[UIApplication sharedApplication] delegate]).isUsingAddressBook=YES;

}

-(void)selectIconAddr:(id)sender{
    [self selectAddressBookAsSource];
    [self.inputSourceSwitch setOn:YES animated:YES];
}


@end
