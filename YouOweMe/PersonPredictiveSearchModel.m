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
#import <FacebookSDK/FacebookSDK.h>

#define MAX_NUM_PREDICTIVE_ROWS_VISIBLE 3

@interface PersonPredictiveSearchModel()
    @property (nonatomic) BOOL isUsingFacebook;
    @property (nonatomic) BOOL isUsingAddressBook;
    @property (nonatomic, strong) NSArray *filteredResults;
    @property (nonatomic, strong) NSArray *allAddressbookContacts;
    @property (nonatomic, strong) UITableView *tableViewWeAreManipulating;
    @property (nonatomic, strong) NSMutableArray *filteredArrayOfPersonObjects;
    //@property (nonatomic, strong) NSArray *facebookFriends;
@end



@implementation PersonPredictiveSearchModel

@synthesize inputString = _inputString;
@synthesize allAddressbookContacts;
@synthesize isUsingAddressBook;
@synthesize isUsingFacebook;
@synthesize filteredResults=_filteredResults;
@synthesize tableViewWeAreManipulating;
@synthesize delegate;
@synthesize filteredArrayOfPersonObjects;

//@synthesize facebookFriends;

#pragma mark - instance vars

int calculatedCellHeight=0;
int originalTableHeight=0;

#pragma mark - getters & setters

-(void)setFilteredResults:(NSArray *)filteredResults{
    _filteredResults = filteredResults;
    self.filteredArrayOfPersonObjects = [[NSMutableArray alloc] init];
    if(self.isUsingAddressBook){
        for(int i=0;i<_filteredResults.count;i++){
            ABRecordRef ref = CFArrayGetValueAtIndex((__bridge CFArrayRef)(_filteredResults), i);
            NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(ref,kABPersonFirstNameProperty);
            if(!firstName)
                firstName = @"";
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(ref,kABPersonLastNameProperty);
            if(!lastName)
                lastName=@"";
            NSData *avatar = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
            if(!avatar){
                avatar = [[NSData alloc] initWithBytes:[@"1" UTF8String] length:strlen([@"1" UTF8String])];
            }
            
            NSString *recordId = [[NSNumber numberWithInteger:ABRecordGetRecordID(ref)] stringValue];
            
            //NSLog(@"first name is %@",firstName);
            //NSLog(@"last name is %@",lastName);
            //NSLog(@"record id is %@",recordId);
            
            NSDictionary *attributes = [[NSDictionary alloc]
                                        initWithObjects:
                                        [NSArray arrayWithObjects:  firstName,    lastName,   avatar,   recordId, SOURCE_ADDRESSBOOK, nil]           forKeys:
                                        [NSArray arrayWithObjects:@"firstName", @"lastName", @"avatar", @"addressBookId", @"source", nil]];
            
            [self.filteredArrayOfPersonObjects addObject:[[CoreDataDBManager initAndRetrieveSharedInstance] personWithAttributes:attributes fromSource:SOURCE_ADDRESSBOOK]];
        }
    }else if(self.isUsingFacebook){
        //nothing
        self.filteredArrayOfPersonObjects = [NSMutableArray arrayWithArray:filteredResults];
    }
    
    [self.tableViewWeAreManipulating reloadData];
}


#pragma mark - PUBLIC API
#pragma mark -

-(void)setInputString:(NSString *)inputString{
    _inputString = inputString;
    
    
    //filter addressbook results
    //
    if(self.isUsingAddressBook){
        
        NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
            BOOL result = NO;
            if(record){
                ABRecordRef *castRecord = (__bridge ABRecordRef)(record);
                NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(castRecord,kABPersonFirstNameProperty);
                //NSLog(@"filtering, looking at first name: %@", firstName);
                if ([[firstName lowercaseString] hasPrefix:[_inputString lowercaseString]]){
                    result = YES;
                }
                //CFRelease(castRecord);
            }
            return result;
        }];
        if([_inputString length]>0){
            if(self.allAddressbookContacts.count<1){
                NSLog(@"all addressbook contacts <1");
            }
            self.filteredResults = [[self.allAddressbookContacts filteredArrayUsingPredicate:predicate] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                //ABRecordRef *castObj1 = (__bridge ABRecordRef)(obj1);
                //ABRecordRef *castObj2 = (__bridge ABRecordRef)(obj2);
                //NSString* name1 = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef) obj1,kABPersonFirstNameProperty);
                //NSString* name2 =(__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef) obj2,kABPersonFirstNameProperty);
                //CFRelease(castObj1);
               // CFRelease(castObj2);
                //return (NSComparisonResult)[name1 compare:name2];
                NSString* name1 = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(obj1),kABPersonFirstNameProperty);
                NSString* name2 =(__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(obj2),kABPersonFirstNameProperty);
                return (NSComparisonResult)[name1 compare:name2];
            }];
            if(self.filteredResults.count<1){
                NSLog(@"filtered contacts <1");
            }
        }else{
            self.filteredResults = [[NSArray alloc] init];
        }
            
    }
    
    //filter facebook results
    //
    if(self.isUsingFacebook){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(firstName BEGINSWITH[cd] %@) AND (source == %@)",inputString, SOURCE_FACEBOOK];

        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == '100004292588508'"];
        self.filteredResults = [[CoreDataDBManager initAndRetrieveSharedInstance] getPersonsWithPredicate:predicate];
    }
}

-(void)setAsDataSourceAndDelegateFor:(UITableView*)tableView{
    self.tableViewWeAreManipulating = tableView;
    self.tableViewWeAreManipulating.userInteractionEnabled=YES;
    self.tableViewWeAreManipulating.canCancelContentTouches=NO;
    self.tableViewWeAreManipulating.dataSource = self;
    self.tableViewWeAreManipulating.delegate = self;
}

-(void)refreshTable{
    [self.tableViewWeAreManipulating reloadData];
}

-(void)refreshSourcesWithFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn;{
    if(facebookOn == self.isUsingFacebook && addressOn==self.isUsingAddressBook){
        NSLog(@"source didn't change, ignore");
    }else{
        NSLog(@"source changed, have to reinitialize");
        [self setupSourcesWithFacebook:facebookOn andAddress:addressOn];
    }
}


#pragma mark - SETUP
#pragma mark - initialiser

-(id)initWithSourcesFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn{
    self = [super init];
    if(!self) return nil;
    
    self.filteredResults = [[NSArray alloc] init];
    NSLog(@"facebook: %d, addressbook:%d", facebookOn, addressOn);

    [self setupSourcesWithFacebook:facebookOn andAddress:addressOn];
    
    return self;
}

-(void)setupSourcesWithFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn{
    self.isUsingAddressBook=addressOn;
    self.isUsingFacebook=facebookOn;
    
    if(facebookOn){
        //ok so here's an extended explanation of the workflow for fetching the fb friend data:
        //fetch the friends with the normal call.
        //In order to not overdo it, store 1 byte in the 'avatar' field.
        //When the appropriate person gets displayed in the tableview, THAT'S when we fetch the user's picture
        //At that time obviously display the picture, but also
        //update the coredata model with the fetched image, overwriting the 1 byte placeholder.
        
        //But for now:
        //Either get the friends (if the session has been properly initialised) OR start listening for when
        //the session has been properly initalised, and then go about our business.
        
        //self.isUsingFacebook=YES;
        
        [self getFacebookFriendsWithCompletionBlock:^(BOOL success, NSError *error) {
            if(success){
                //hey, we got the friends list a-ok! good job
                NSLog(@"facebook friend request success from initWithSourcesFacebook");
                return;
            }else{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionChanged:) name:FBSessionDidBecomeOpenActiveSessionNotification object:nil];
            }
        }];
    }else{
        self.isUsingFacebook=NO;
    }
    
    if(addressOn){
        //initialise addressbook        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                // First time access has been granted
                //[self _addContactToAddressBook];
                NSLog(@"access to addressbook granted");
                [self setupAddressbookAccess];
                CFRelease(addressBookRef);
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
    }else{
        self.isUsingAddressBook=NO;
    }
}

#pragma mark - addressbook
-(void)setupAddressbookAccess{
    
    //self.isUsingAddressBook=YES;
    
    ABAddressBookRef *addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    self.allAddressbookContacts = (__bridge_transfer NSArray *)allPeople;
}









#pragma mark - TABLEVIEW
#pragma mark - table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"did select row at index path");
    return;
    
    /*NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonFirstNameProperty);
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
                                [NSArray arrayWithObjects:  firstName,    lastName,   avatar,   recordId, SOURCE_ADDRESSBOOK, nil]           forKeys:
                                [NSArray arrayWithObjects:@"firstName", @"lastName", @"avatar", @"addressBookId", @"source", nil]];

    Person *p = [[CoreDataDBManager initAndRetrieveSharedInstance] personWithAttributes:attributes fromSource:SOURCE_ADDRESSBOOK];

    [self.delegate didSelectPerson:p];*/
}

#pragma mark - table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"PredictiveResultsCell";
    PredictiveSearchResult *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[PredictiveSearchResult alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    /*NSString *name;
    NSString *recordId = [[NSNumber numberWithInteger:ABRecordGetRecordID((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]))] stringValue];
    
    
    NSData  *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]), kABPersonImageFormatThumbnail);
    if(imgData){
        [cell.avatar setImage:[UIImage imageWithData:imgData]];
        cell.avatar.layer.borderColor = [[UIColor colorWithRed:53.0f/255.0f green:130.0f/255.0f blue:189.0f/255.0f alpha:1.0f] CGColor];
        cell.avatar.layer.borderWidth = 0.0f;
    }else{
        NSLog(@"there was no image for %@", name);
        [cell.avatar setImage:[UIImage imageNamed:@"default-user-image.png"]];
    }
    
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonFirstNameProperty);
    if(!firstName)
        firstName = @"";
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(CFBridgingRetain([self.filteredResults objectAtIndex:indexPath.row]),kABPersonLastNameProperty);
    if(!lastName)
        lastName=@"";
    if(lastName)
        name = [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
    else
        name = firstName;
    NSData *avatar = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat((__bridge ABRecordRef)([self.filteredResults objectAtIndex:indexPath.row]), kABPersonImageFormatThumbnail);
    if(!avatar){
        //avatar = [[NSData alloc] initWithBytes:[@"1" UTF8String] length:strlen([@"1" UTF8String])];
        UIImage *defaultAvatar = [UIImage imageNamed:@"default-user-image.png"];
        avatar = UIImagePNGRepresentation(defaultAvatar);
    }
    
    NSLog(@"first name is %@",firstName);
    NSLog(@"last name is %@",lastName);
    NSLog(@"record id is %@",recordId);
    
    NSDictionary *attributes = [[NSDictionary alloc]
                                initWithObjects:
                                [NSArray arrayWithObjects:  firstName,    lastName,   avatar,   recordId, @"addressbook", nil]           forKeys:
                                [NSArray arrayWithObjects:@"firstName", @"lastName", @"avatar", @"addressBookId", @"source", nil]];
    */
  
    Person *p = [self.filteredArrayOfPersonObjects objectAtIndex:indexPath.row];
    if(self.isUsingAddressBook)
        cell.uniqueIdSource = SOURCE_ADDRESSBOOK;
    else if (self.isUsingFacebook)
        cell.uniqueIdSource = SOURCE_FACEBOOK;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self.delegate;
    cell.person = p;
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





#pragma mark - FACEBOOK
#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // first get the buttons set for login mode
    NSLog(@"loginViewShowingLoggedInUser");
    [self getFacebookFriendsWithCompletionBlock:^(BOOL success, NSError *error) {
        if(success){
            //hey, we got the friends list a-ok! good job
            NSLog(@"facebook friends retrieved ok from loginViewShowingLoggedInUser");
            return;
        }else{
            NSLog(@"loginViewShowingLoggedInUser, something went wrong retrieving the fb friends");
        }
    }];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"loginViewFetchedUserInfo");
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    
    //self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    //self.profilePic.profileID = user.id;
    //self.loggedInUser = user;
}


-(void)getFacebookFriendsWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionHandler{
    
    
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        
        if(error){
            NSLog(@"error retrieving FB data: %@", error.description);
            completionHandler(NO, error);
        }
        
        if([friends count]<1){
            NSLog(@"error retriving FB data: zero friends");
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"error retrieving FB data: zero friends" forKey:NSLocalizedDescriptionKey];
            
            NSError *myError = [[NSError alloc] initWithDomain:ERROR_DOMAIN code:1 userInfo:details];
            completionHandler(NO, myError);
        }else{
            completionHandler(YES,nil);
            //self.facebookFriends = friends;
            
            NSLog(@"Found: %i friends", friends.count);
            for (NSDictionary<FBGraphUser>* friend in friends) {
                //NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);

                NSDictionary *attributes = [[NSDictionary alloc]
                                            initWithObjects:
                                            [NSArray arrayWithObjects:
                                             friend.first_name,
                                             friend.last_name,
                                             [[NSData alloc] initWithBytes:[@"1" UTF8String] length:strlen([@"1" UTF8String])],
                                             friend.id,
                                             SOURCE_FACEBOOK,
                                             nil]
                                            forKeys:
                                            [NSArray arrayWithObjects:@"firstName", @"lastName", @"avatar", @"facebookId", @"source", nil]];
                [[CoreDataDBManager initAndRetrieveSharedInstance] personWithAttributes:attributes fromSource:SOURCE_FACEBOOK];
            }
        }
    }];
}

-(void)facebookSessionChanged:(NSNotification*)notification{
    NSLog(@"search model fb session changed");
    
    [self getFacebookFriendsWithCompletionBlock:^(BOOL success, NSError *error) {
        if(success){
            //hey, we got the friends list a-ok! good job
            NSLog(@"facebook friends retrieved from facebookSessionChanged");
            [[NSNotificationCenter defaultCenter] removeObserver:self name:FBSessionDidBecomeOpenActiveSessionNotification object:nil];
            return;
        }else{
            NSLog(@"facebookSessionChanged, something went wrong retrieving the fb friends");
        }
    }];
}



@end
