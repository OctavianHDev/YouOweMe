//
//  PredictiveSearchResult.h
//  YouOweMe
//
//  Created by o on 13-02-21.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonPredictiveSearchModel.h"

@interface PredictiveSearchResult : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblName;
@property (nonatomic, strong) IBOutlet UIImageView *avatar;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewBackgroundImage;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic, strong) NSString *uniqueIdSource;
@property (nonatomic, weak) id<PredictiveSearchDelegate> delegate;

@end
