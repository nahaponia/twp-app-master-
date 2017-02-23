//
//  AppDataManager.m
//  SportWorldPassport
//
//  Created by star on 12/15/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "AppDataManager.h"

@implementation AppDataManager

static AppDataManager *sharedInstance = nil;

+ (AppDataManager *)instance
{
    if(!sharedInstance) {
        sharedInstance = [[AppDataManager alloc] init];
        sharedInstance.followerArray = [[NSMutableArray alloc] init];
        sharedInstance.bannedArray = [[NSMutableArray alloc] init];
        sharedInstance.blockedArray = [[NSMutableArray alloc] init];
        sharedInstance.blockdedIdArray = [[NSMutableArray alloc] init];
    }
    return sharedInstance;
}

@end
