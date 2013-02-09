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

@synthesize tableView;
@synthesize tableViewPredictiveSearchResults;

NSArray *tableContents;


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
    }}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(CGRectIntersectsRect(scrollView.bounds, CGRectMake(0, -30, scrollView.bounds.size.width, 1))){
        //insert new cell at the top of the table
        NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];

        if(tableContents.count<1){
            [self.tableView beginUpdates];
            tableContents = [NSArray arrayWithObject:[NSNumber numberWithInt:1]];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            //self.tableView.scrollEnabled=NO;
            self.tableView.bounces=NO;
            [self.tableView endUpdates];
        }
    }
}

#pragma mark - UITableView DataSource

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"HomeScreenCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(cell==nil){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DebtorNameInputCellView" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        
        ((DebtorNameInputCellView *)cell).debtorNameTextInput.text = @"HELLO!!!";
        ((DebtorNameInputCellView *)cell).backgroundView.backgroundColor = [UIColor blueColor];
        ((DebtorNameInputCellView *)cell).backgroundView.alpha=1.0f;
        ((DebtorNameInputCellView *)cell).delegate=self;
        
        cell.layer.shadowRadius=5.0f;
        cell.layer.shadowColor=[[UIColor blackColor] CGColor];
        cell.layer.shadowOpacity=0.7f;
        cell.layer.masksToBounds=NO;
        //cell.backgroundColor = [UIColor colorWithRed:0.0/255 green:0.0/255 blue:254/255.0 alpha:1.0f];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"tableContents.count: %d", tableContents.count);
    return tableContents.count;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - view lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    tableContents = [[NSArray alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - delete me
-(void)resetPressed:(id)sender{
    NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if(tableContents.count>0){
        [self.tableView beginUpdates];
        tableContents = [[NSArray alloc] init];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        self.tableView.bounces=YES;
    }


}

@end
