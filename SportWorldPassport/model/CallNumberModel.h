//
//  CallNumberModel.h
//  SportWorldPassport
//
//  Created by star on 11/27/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallNumberModel : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, assign) int prefixStatus;

@end
