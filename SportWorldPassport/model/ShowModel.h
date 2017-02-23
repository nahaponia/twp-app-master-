//
//  ShowModel.h
//  FANster
//
//  Created by star on 7/13/15.
//  Copyright (c) 2015 com.zapporoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowModel : NSObject

@property (nonatomic, strong) NSString *venue;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *price;

+ (id)instanceWithVenue:(NSString *)venue
                Address:(NSString *)address
                   City:(NSString *)city
                  State:(NSString *)state
                Country:(NSString *)country
                   Date:(NSString *)date
              StartTime:(NSString *)startTime
                  Price:(NSString *)price;
@end
