//
//  ShowModel.m
//  FANster
//
//  Created by star on 7/13/15.
//  Copyright (c) 2015 com.zapporoo. All rights reserved.
//

#import "ShowModel.h"

@implementation ShowModel

+ (id)instanceWithVenue:(NSString *)venue
                Address:(NSString *)address
                   City:(NSString *)city
                  State:(NSString *)state
                Country:(NSString *)country
                   Date:(NSString *)date
              StartTime:(NSString *)startTime
                  Price:(NSString *)price {
    
    ShowModel *model = [[ShowModel alloc] init];
    model.venue = venue;
    model.address = address;
    model.city = city;
    model.state = state;
    model.country = country;
    model.date = date;
    model.startTime = startTime;
    model.price = price;
    
    return model;
}

@end
