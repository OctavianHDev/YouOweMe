//
//  ImageCache.m
//  YouOweMe
//
//  Created by o on 13-02-28.
//  Copyright (c) 2013 o. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

@synthesize cachedImages;

static dispatch_once_t pred;
static ImageCache *imageCache=nil;

+(ImageCache *)getInstance{
    dispatch_once(&pred, ^{
        imageCache = [[ImageCache alloc] init];
        [imageCache initializeObjects];
    });
    return imageCache;
}

-(void)resetCache{
    self.cachedImages = [[NSMutableDictionary alloc] init];
}

-(void)initializeObjects{
    self.cachedImages = [[NSMutableDictionary alloc] init];
}

@end
