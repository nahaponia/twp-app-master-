//
//  AppDelegate.m
//  SportWorldPassport
//
//  Created by star on 11/30/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import <stripe/Stripe.h>

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Crashlytics/Crashlytics.h>
#import "AppConfig.h"
#import "ShareViewController.h"

@interface AppDelegate ()
{
    CLLocationManager *locationManager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [Fabric with:@[[Crashlytics class], [STPAPIClient class]]];
    
    //location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.allowsBackgroundLocationUpdates = NO;
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    
    [PFUser enableAutomaticUser];
//    [Parse setApplicationId:PARSE_APPID clientKey:PARSE_CLIENT_KEY];
    // parse to Heroku
//    [Parse initializeWithConfiguration:[ParseClientConfiguration
//                                        configurationWithBlock:^(id<ParseMutableClientConfiguration>
//                                                                 configuration) {
//                                            configuration.applicationId = PARSE_APPID;
//                                            configuration.clientKey = PARSE_CLIENT_KEY;
//                                            configuration.server = @"http://sportsworldpassportdatabase.herokuapp.com/parse";
//                                        }]];
    // parse to back4app.com
    [Parse initializeWithConfiguration:[ParseClientConfiguration
                                    configurationWithBlock:^(id<ParseMutableClientConfiguration>
                                                          configuration) {
                                       configuration.applicationId = PARSE_APPID;
                                       configuration.clientKey = PARSE_CLIENT_KEY;
                                       configuration.server = @"https://parseapi.back4app.com/";
                                }]];
    
    [PFUser enableRevocableSessionInBackground];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    PFInstallation *currentInstall = [PFInstallation currentInstallation];
    if (currentInstall) {
        currentInstall.badge = 0;
        [currentInstall saveInBackground];
    }
    
    // Stripe
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    // Neumob
//    [Neumob initialize:NEUMOB_CLIENT_KEY completionHandler:^{
//        if ([Neumob initialized]){
//            NSLog(@"Neumob initialized success!");
//        } else {
//            NSLog(@"Neumob initialized failure!");
//        }
//    }];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else
#endif
    {
        [application registerForRemoteNotificationTypes:(
                                                         UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    // Facebook
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

// Facebook
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if ([[url scheme] isEqualToString:@"travelworldpassport"] == YES) { //Twitter in ShareViewController
        NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
        
//        NSString *token = d[@"oauth_token"];
//        NSString *verifier = d[@"oauth_verifier"];
        
        //    ShareViewController *vc = (ShareViewController *)[[self window] rootViewController];
        //    [vc setOAuthToken:token oauthVerifier:verifier];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil userInfo:d];
    } else if ([[url scheme] isEqualToString:@"fb298777997188130"]) { //Facebook
        
    } else if ([[url scheme] isEqualToString:@"travelworldpassports"]){ //Twitter in FeedDetailViewController
        NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
        
//        NSString *token = d[@"oauth_token"];
//        NSString *verifier = d[@"oauth_verifier"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViewTwitter" object:nil userInfo:d];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
#pragma mark Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
    } else { // active status
        application.applicationIconBadgeNumber = 0;
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [locationManager startUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Facebook
    [FBSDKAppEvents activateApp];
    application.applicationIconBadgeNumber = 0;
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *currentLocation = [locations lastObject];
    [AppConfig getAddressFromLocation:currentLocation complationBlock:^(NSString *address){
        [locationManager stopUpdatingLocation];
    }];
}
@end
