//
//  DeliveryAndBillingModel.h
//  SportWorldPassport
//
//  Created by User 10 on 7/24/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeliveryAndBillingModel : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *postcode;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSString *expireDate;
@property (nonatomic, strong) NSString *cvv;

@end
