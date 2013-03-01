//
//  ImageCache.h
//  YouOweMe
//
//  Created by o on 13-02-28.
//  Copyright (c) 2013 o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject


@property (nonatomic, strong) NSMutableDictionary *cachedImages;

+(ImageCache *)getInstance;
-(void)resetCache;


@end
