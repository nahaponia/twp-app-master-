//
//  CallHistoryManager.h
//  SportWorldPassport
//
//  Created by star on 11/29/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallHistoryManager : NSObject

+ (void)getPrivateDBs;
+ (NSArray *)getCallHistoryList;

@end
