//
//  PrintStampTwoViewController.h
//  SportWorldPassport
//
//  Created by User 10 on 7/16/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeliveryAndBillingModel;
@interface PrintStampTwoViewController : UIViewController

@property (nonatomic, strong) DeliveryAndBillingModel* model;
@property (nonatomic, strong) STPToken* stripeToken;
@property (nonatomic, strong) NSMutableArray *stampArray;

@end
