//
//  HomeViewController.m
//  YouOweMe
//
//  Created by o on 13-02-02.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController ()
    @property (nonatomic, strong) PersonPredictiveSearchModel *predictiveSearchDataSource;
@end


@implementation HomeViewController


#pragma mark - getters/setters/synthesizers

@synthesize gestureRecognitionView, predictiveSearchResults;
@synthesize inputView;
@synthesize predictiveSearchDataSource=_predictiveSearchDataSource;
@synthesize debtDatabase = _debtDatabase;


-(PersonPredictiveSearchModel*)predictiveSearchDataSource{
    if(!_predictiveSearchDataSource)
        _predictiveSearchDataSource = [[PersonPredictiveSearchModel alloc] initWithSourcesFacebook:NO andAddress:YES];
    return _predictiveSearchDataSource;
}





#pragma mark - instance vars

UIPanGestureRecognizer *panGestureRecognizer;




#pragma mark - PredictiveSearchDelegate delegate

-(void)didSelectPerson:(Person*)person{
    NSLog(@"selected person: %@ %@", person.firstName, person.lastName);
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



#pragma mark - coredata stuff

-(void)setupFetchedResultsController{

}

-(void)useDocument{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.debtDatabase.fileURL path]]){
        [self.debtDatabase saveToURL:self.debtDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
    }else if (self.debtDatabase.documentState ==UIDocumentStateClosed){
            [self setupFetchedResultsController];
    }else if (self.debtDatabase.documentState ==UIDocumentStateNormal){
            [self setupFetchedResultsController];
    }
    
}


-(void)setDebtDatabase:(UIManagedDocument *)debtDatabase{
    _debtDatabase = debtDatabase;
    [self useDocument];
}

#pragma mark - view lifeCycle

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!self.debtDatabase){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Debt Database"];
        self.debtDatabase = [[UIManagedDocument alloc]initWithFileURL:url];
        
    }
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
    [self.predictiveSearchDataSource setAsDataSourceAndDelegateFor:self.predictiveSearchResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
