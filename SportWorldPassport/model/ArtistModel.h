//
//  ArtistModel.h
//  FANster
//
//  Created by star on 7/24/15.
//  Copyright (c) 2015 com.zapporoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArtistModel : NSObject

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) int followCount;

@end
