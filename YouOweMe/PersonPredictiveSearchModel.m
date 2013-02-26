//
//  PersonPredictiveSearchModel.m
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "PersonPredictiveSearchModel.h"
#import <AddressBook/AddressBook.h>
#import "PredictiveSearchResult.h"


#define MAX_NUM_PREDICTIVE_ROWS_VISIBLE 3

@interface PersonPredictiveSearchModel()
    @property (nonatomic) BOOL isUsingFacebook;
    @property (nonatomic) BOOL isUsingAddressBook;
    @property (nonatomic, strong) NSArray *filteredResults;
    @property (nonatomic, strong) NSArray *allAddressbookContacts;
    @property (nonatomic, strong) UITableView *tableViewWeAreManipulating;
@end



@implementation PersonPredictiveSearchModel

@synthesize inputString = _inputString;
@synthesize allAddressbookContacts;
@synthesize isUsingAddressBook;
@synthesize isUsingFacebook;
@synthesize filteredResults=_filteredResults;
@synthesize tableViewWeAreManipulating;
@synthesize delegate;

-(void)setFilteredResults:(NSArray *)filteredResults{
    _filteredResults = filteredResults;
    for(int i=0;i<_filteredResults.count;i++){
        NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([_filteredResults objectAtIndex:i]),kABPersonFirstNameProperty);
        NSLog(@"filtered first name is: %@", firstName);
    }
    [self.tableViewWeAreManipulating reloadData];
}


#pragma mark - public API

-(void)setInputString:(NSString *)inputString{
    _inputString = inputString;
    
    
    //filter addressbook results
    //
    if(self.isUsingAddressBook){
        
        NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
            BOOL result = NO;
            if(record){
                NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(record),kABPersonFirstNameProperty);
                //NSLog(@"filtering, looking at first name: %@", firstName);
                if ([firstName hasPrefix:_inputString]){
                    result = YES;
                }
            }
            return result;
        }];
        self.filteredResults = [self.allAddressbookContacts filteredArrayUsingPredicate:predicate];
    }
    
    //filter facebook results
    //
    if(self.isUsingFacebook){
    
    }
}

-(void)setAsDataSourceAndDelegateFor:(UITableView*)tableView{
    self.tableViewWeAreManipulating = tableView;
    self.tableViewWeAreManipulating.userInteractionEnabled=YES;
    self.tableViewWeAreManipulating.dataSource = self;
    self.tableViewWeAreManipulating.delegate = self;
}


#pragma makr - table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Person *p = [[Person alloc] init];
    p.firstName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonFirstNameProperty);
    p.lastName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonLastNameProperty);
    p.avatar = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]), kABPersonImageFormatThumbnail);
    [self.delegate didSelectPerson:p];
}

-(void)gestureRecognizerHandler:(id)gesture{
    NSLog(@"HELLO!");
}

#pragma mark - table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"PredictiveResultsCell";
    PredictiveSearchResult *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[PredictiveSearchResult alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonFirstNameProperty);
    
    NSData  *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]), kABPersonImageFormatThumbnail);
    if(imgData){
        [cell.avatar setImage:[UIImage imageWithData:imgData]];
    }else{
        NSLog(@"there was no image for %@", firstName);
    }
    
    UITapGestureRecognizer *tapr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler)];
    [cell addGestureRecognizer:tapr];
    
    cell.name=firstName;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numResults = self.filteredResults.count;
    if(numResults<1)
        self.tableViewWeAreManipulating.hidden=YES;
    else{
        self.tableViewWeAreManipulating.hidden=NO;
        if(numResults<MAX_NUM_PREDICTIVE_ROWS_VISIBLE){
            CGRect newTableFrame = CGRectMake(self.tableViewWeAreManipulating.frame.origin.x,
                                          self.tableViewWeAreManipulating.frame.origin.y,
                                          self.tableViewWeAreManipulating.frame.size.width,
                                          numResults * [self tableView:self.tableViewWeAreManipulating heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]
                                          );
            self.tableViewWeAreManipulating.frame=newTableFrame;
        }
    }
    return numResults;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PredictiveSearchResult"
                                                             owner:self
                                                           options:nil];
    UITableViewCell *cell = [topLevelObjects objectAtIndex:0];

    return cell.frame.size.height;
}



#pragma mark - setup 

-(id)initWithSourcesFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn{
    self = [super init];
    if(!self) return nil;
    
    self.filteredResults = [[NSArray alloc] init];
    
    if(facebookOn){
        //initialise facebook
    }
    
    if(addressOn){
        //initialise addressbook
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                // First time access has been granted
                //[self _addContactToAddressBook];
                NSLog(@"access to addressbook granted");
                [self setupAddressbookAccess];
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access
            //[self _addContactToAddressBook];
            NSLog(@"the user has previously given access");
            [self setupAddressbookAccess];
        }
        else {
            // The user has previously denied access
            // Send an alert telling user to change privacy setting in settings app
            NSLog(@"the user has previously denied access");
        }
    }
    return self;
}

-(void)setupAddressbookAccess{

    self.isUsingAddressBook=YES;
    
    ABAddressBookRef *addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0; i<numPeople;i++){
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(ref,kABPersonFirstNameProperty);
        NSLog(@"setup addressbook: looking at first name: %@", firstName);
    }
    
    self.allAddressbookContacts = (__bridge_transfer NSArray *)allPeople;
}

@end
