//
//  LatestDebtsDataSource.m
//  YouOweMe
//
//  Created by o on 13-03-28.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "LatestDebtsDataSource.h"
#import "PredictiveSearchResult.h"
#import "Constants.h"
#import "CoreDataDBManager.h"

@interface LatestDebtsDataSource()
    @property (nonatomic) BOOL isUsingFacebook;
    @property (nonatomic) BOOL isUsingAddressBook;
    @property (nonatomic, readonly, strong) NSArray *filteredArray;
    @property (nonatomic)int calculatedCellHeight;
    @property (nonatomic)int originalTableHeight;

@end

@implementation LatestDebtsDataSource


@synthesize isUsingFacebook,isUsingAddressBook;
@synthesize filteredArray=_filteredArray;




#pragma mark - PUBLIC API
#pragma mark -

-(void)setAsUsingFacebook:(BOOL)facebookOn andAddressBook:(BOOL)addressBookOn{
    self.isUsingAddressBook=addressBookOn;
    self.isUsingFacebook=facebookOn;
}

-(NSArray*)filteredArray{
    NSString *source;
    int numResults = 5;
    if(self.isUsingFacebook)
        source = SOURCE_FACEBOOK;
    if(self.isUsingAddressBook)
        source = SOURCE_ADDRESSBOOK;
    _filteredArray = [[CoreDataDBManager initAndRetrieveSharedInstance] getPersonsWithMostRecentDebts:[NSNumber numberWithInt:numResults] fromSource:source];
    return _filteredArray;
}






#pragma mark - TABLEVIEW
#pragma mark - table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"did select row at index path");
    return;

}

#pragma mark - table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"PredictiveResultsCell";
    PredictiveSearchResult *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[PredictiveSearchResult alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Person *p = [self.filteredArray objectAtIndex:indexPath.row];
    if(self.isUsingAddressBook)
        cell.uniqueIdSource = SOURCE_ADDRESSBOOK;
    else if (self.isUsingFacebook)
        cell.uniqueIdSource = SOURCE_FACEBOOK;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.delegate = self.delegate;
    cell.person = p;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.calculatedCellHeight<1){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PredictiveSearchResult"
                                                                 owner:self
                                                               options:nil];
        UITableViewCell *cell = [topLevelObjects objectAtIndex:0];
        self.calculatedCellHeight = cell.frame.size.height;
    }
    return self.calculatedCellHeight;
}




@end
