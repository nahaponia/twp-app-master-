//
//  AppConfig.m
//  SportWorldPassport
//
//  Created by star on 7/12/15.
//  Copyright (c) 2015 com.UWP. All rights reserved.
//

#import "AppConfig.h"

NSString *const StripePublishableKey = @"pk_live_mzyMhOYBic1aFf3UFxx4IhDa";//client test key
//NSString *const StripePublishableKey = @"pk_live_mzyMhOYBic1aFf3UFxx4IhDa";//client live key
NSString *const BackendChargeURLString = @"https://stripebackendswp.herokuapp.com"; //new

@implementation AppConfig

+ (void)setStringValueForKey:(NSString *)key value:(NSString *)value {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:value forKey:key];
    [userDefault synchronize];
}

+ (NSString *)getStringValueForKey:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefault stringForKey:key];
    if (value == nil) {
        value = @"";
    }
    return value;
}

+ (void)setBoolValueForKey:(NSString *)key value:(BOOL)value {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:value forKey:key];
    [userDefault synchronize];
}

+ (BOOL)getBoolValueForKey:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL value = [userDefault boolForKey:key];
    return value;
}

+(NSString *)getAddressFromLatLon
{
    latitude = [self getStringValueForKey:kGeoLatitude].doubleValue;
    longitude = [self getStringValueForKey:kGeoLongitude].doubleValue;
    NSString *urlString = [NSString stringWithFormat:kGeoCodingString,latitude, longitude];
    NSError* error;
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
    locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [locationString substringFromIndex:6];
}

+(void)getAddressFromLocation:(CLLocation *)location complationBlock:(addressCompletion)completionBlock
{
    __block CLPlacemark* placemark;
    __block NSString *address = nil;
    
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count] > 0)
         {
             placemark = [placemarks lastObject];
             address = [NSString stringWithFormat:@"%@, %@", placemark.name, placemark.country];
             localization = address;
             completionBlock(address);
         }
     }];
}
+(NSString *) getLocalization
{
    return localization;
}

+ (void) setDeliveryModel:(DeliveryAndBillingModel *)modelling
{
    model = modelling;
}

+ (DeliveryAndBillingModel *) getDeliveryModel
{
    return model;
}

@end
