//
//  PersonPredictiveSearchModel.m
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "PersonPredictiveSearchModel.h"
#import <AddressBookUI/AddressBookUI.h>

@implementation PersonPredictiveSearchModel


#pragma mark - table view data source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{}



#pragma mark - lifecycle

-(id)initWithSourcesFacebook:(BOOL)facebookOn andAddress:(BOOL)addressOn{
    self = [super init];
    if(!self) return nil;
    
    if(facebookOn){
        //initialise facebook
    }
    
    if(addressOn){
        //initialise addressbook
    }
}

/*#pragma mark - Address book stuff

- (void)showPicker:(id)sender
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
    }
}*/



@end
