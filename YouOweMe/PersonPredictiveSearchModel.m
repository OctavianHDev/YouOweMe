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
#import <QuartzCore/QuartzCore.h>
#import "Person+Create.h"
#import "CoreDataDBManager.h"
#import "Constants.h"


#define MAX_NUM_PREDICTIVE_ROWS_VISIBLE 3

@interface PersonPredictiveSearchModel()
    @property (nonatomic) BOOL isUsingFacebook;
    @property (nonatomic) BOOL isUsingAddressBook;
    @property (nonatomic, strong) NSArray *filteredResults;
    @property (nonatomic, strong) NSArray *allAddressbookContacts;
    @property (nonatomic, strong) UITableView *tableViewWeAreManipulating;
    @property (nonatomic, strong) NSManagedObjectContext *moc;
@end



@implementation PersonPredictiveSearchModel

@synthesize inputString = _inputString;
@synthesize allAddressbookContacts;
@synthesize isUsingAddressBook;
@synthesize isUsingFacebook;
@synthesize filteredResults=_filteredResults;
@synthesize tableViewWeAreManipulating;
@synthesize moc;
@synthesize delegate;


#pragma mark - instance vars

int calculatedCellHeight=0;
int originalTableHeight=0;

#pragma mark - getters & setters

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
                if ([[firstName lowercaseString] hasPrefix:[_inputString lowercaseString]]){
                    result = YES;
                }
            }
            return result;
        }];
        if([_inputString length]>0){
            self.filteredResults = [[self.allAddressbookContacts filteredArrayUsingPredicate:predicate] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString* name1 = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(obj1),kABPersonFirstNameProperty);
                NSString* name2 =(__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(obj2),kABPersonFirstNameProperty);
                return (NSComparisonResult)[name1 compare:name2];
                
            }];
        }else{
            self.filteredResults = [[NSArray alloc] init];
        }
            
    }
    
    //filter facebook results
    //
    if(self.isUsingFacebook){
    
    }
}

-(void)setAsDataSourceAndDelegateFor:(UITableView*)tableView{
    self.tableViewWeAreManipulating = tableView;
    self.tableViewWeAreManipulating.userInteractionEnabled=YES;
    self.tableViewWeAreManipulating.canCancelContentTouches=NO;
    self.tableViewWeAreManipulating.dataSource = self;
    self.tableViewWeAreManipulating.delegate = self;
}

#pragma mark - table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"did select row at index path");
    return;
    
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonFirstNameProperty);
    if(!firstName)
        firstName = @"";
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonLastNameProperty);
    if(!lastName)
        lastName=@"";
    NSData *avatar = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]), kABPersonImageFormatThumbnail);
    if(!avatar){
        //avatar = [[NSData alloc] initWithBytes:[@"1" UTF8String] length:strlen([@"1" UTF8String])];
        UIImage *defaultAvatar = [UIImage imageNamed:@"default-user-image.png"];
        avatar = UIImagePNGRepresentation(defaultAvatar);
    }
    NSString *recordId = [[NSNumber numberWithInteger:ABRecordGetRecordID((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]))] stringValue];

    NSLog(@"first name is %@",firstName);
    NSLog(@"last name is %@",lastName);
    NSLog(@"record id is %@",recordId);
    
    NSDictionary *attributes = [[NSDictionary alloc]
                                initWithObjects:
                                [NSArray arrayWithObjects:  firstName,    lastName,   avatar,   recordId, @"addressbook", nil]           forKeys:
                                [NSArray arrayWithObjects:@"firstName", @"lastName", @"avatar", @"addressBookId", @"source", nil]];

    Person *p = [[CoreDataDBManager initAndRetrieveSharedInstance] createPersonWithAttributes:attributes];

    [self.delegate didSelectPerson:p];
}

#pragma mark - table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"PredictiveResultsCell";
    PredictiveSearchResult *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[PredictiveSearchResult alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString* firstname = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonFirstNameProperty);
    NSString* lastname = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonLastNameProperty);
    NSString *name;
    NSString *recordId = [[NSNumber numberWithInteger:ABRecordGetRecordID((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]))] stringValue];
    
    if(lastname)
        name = [[firstname stringByAppendingString:@" "] stringByAppendingString:lastname];
    else
        name = firstname;
    
    NSData  *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]), kABPersonImageFormatThumbnail);
    if(imgData){
        [cell.avatar setImage:[UIImage imageWithData:imgData]];
        cell.avatar.layer.borderColor = [[UIColor colorWithRed:53.0f/255.0f green:130.0f/255.0f blue:189.0f/255.0f alpha:1.0f] CGColor];
        cell.avatar.layer.borderWidth = 0.0f;
    }else{
        NSLog(@"there was no image for %@", name);
        [cell.avatar setImage:[UIImage imageNamed:@"default-user-image.png"]];
    }
        
    cell.name=name;
    //cell.lblName.textColor = [UIColor colorWithRed:53.0f/255.0f green:121.0f/255.0f blue:172.0f/255.0f alpha:1.0f];

    cell.lblName.layer.shadowColor = [[UIColor colorWithWhite:1.0f alpha:0.5f] CGColor];
    cell.lblName.layer.shadowOpacity=1.0f;
    cell.lblName.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    cell.lblName.layer.shadowRadius=1;
    
    cell.uniqueId = recordId;
    cell.uniqueIdSource = SOURCE_ADDRESSBOOK;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self.delegate;
    //cell.parentTableView=tableView;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredResults.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(calculatedCellHeight<1){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PredictiveSearchResult"
                                                                 owner:self
                                                               options:nil];
        UITableViewCell *cell = [topLevelObjects objectAtIndex:0];
        calculatedCellHeight = cell.frame.size.height;
    }
    return calculatedCellHeight;
}



#pragma mark - setup 

-(id)initWithSourcesFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn{
    self = [super init];
    if(!self) return nil;
    
    self.filteredResults = [[NSArray alloc] init];
    NSLog(@"facebook: %d, addressbook:%d", facebookOn, addressOn);
    
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
            //TODO: alert the user
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
        //NSLog(@"setup addressbook: looking at first name: %@", firstName);
    }
    
    self.allAddressbookContacts = (__bridge_transfer NSArray *)allPeople;
}

@end
