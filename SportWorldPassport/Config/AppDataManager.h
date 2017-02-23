//
//  AppDataManager.h
//  SportWorldPassport
//
//  Created by star on 12/15/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *followerArray;
@property (nonatomic, strong) NSMutableArray *bannedArray;
@property (nonatomic, strong) NSMutableArray *blockedArray;
@property (nonatomic, strong) NSMutableArray *blockdedIdArray;

+ (AppDataManager *)instance;

@end
