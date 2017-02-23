//
//  AppConfig.h
//  SportWorldPassport
//
//  Created by star on 7/12/15.
//  Copyright (c) 2015 com.UWP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeliveryAndBillingModel.h"

#define APP_NAME                    @"Sport World Passport"
#define TITLE_SUCCESS               @"Success"
#define TITLE_ERROR                 @"Error"
#define TESTFAIRYID                 @"aa95e7525f23b844ae452502ca7eb05f513076b8"

#define DEBUG_MODE                  YES
#define TEST_MODE                   NO

#define LOGINED_USER                @"logined_user"
#define LOGINED_USER_NAME           @"logined_user_name"
#define LOGINED_USER_EMAIL          @"logined_user_email"
#define LOGINED_USER_PASSWORD       @"logined_user_password"

#define LOAD_TIME                   10.0
#define QUICK_LOAD_TIME             2.0

/* ******************** Parse config *************************/

// Sport World Passport
//#define PARSE_APPID                 @"4CmO6BLVjSMbePZuchiGnxpaMJK2xQECqq7GQ458"
//#define PARSE_CLIENT_KEY            @"U7ldg5OZHasuU4o7UFEV0yBw47Fdf0VSfJWLAqRc"

// Travel World Passport
#define PARSE_APPID                 @"NQ5ALKrgUCXOndyb6le52kowPEWidTExahTip3sr"
#define PARSE_CLIENT_KEY            @"cJdNSz0UgwpapH0CYmx20IF3UEjYm2GVaqdrJdOx"

#define NEUMOB_CLIENT_KEY           @"4WXQwhWHVpZXz3mr"

// default fields
#define PARSE_FIELD_USER            @"user"
#define PARSE_FIELD_OBJECT_ID       @"objectId"
#define PARSE_FIELD_CREATED_AT      @"createdAt"
#define PARSE_FIELD_UPDATED_AT      @"updatedAt"

// user table
#define PARSE_USER_USERNAME         @"username"
#define PARSE_USER_FIRSTNAME        @"firstName"
#define PARSE_USER_LASTNAME         @"lastName"
#define PARSE_USER_PASSWORD         @"password"
#define PARSE_USER_EMAIL            @"email"
#define PARSE_USER_EMAIL_VERIFIED   @"emailVerified"
#define PARSE_USER_AVATAR           @"userAvatar"
#define PARSE_USER_CATEGORIES       @"category"
#define PARSE_USER_POST_COUNT       @"postCount"
#define PARSE_USER_BLOCKED          @"blocked"

// feed table
#define PARSE_TABLE_FEED            @"Feed"
#define PARSE_FEED_TITLE            @"title"
#define PARSE_FEED_DESCRIPT         @"description"
#define PARSE_FEED_NORMAL_PHOTO     @"normalPhoto"
#define PARSE_FEED_SMALL_PHOTO      @"smallPhoto"
#define PARSE_FEED_TAGS             @"tags"
#define PARSE_FEED_COMMENTS         @"comments"
#define PARSE_FEED_COMMENT_COUNT    @"commentCount"
#define PARSE_FEED_LIKES            @"likes"
#define PARSE_FEED_LIKE_COUNT       @"likeCount"
#define PARSE_FEED_TREND_COUNT      @"trendCount"
#define PARSE_FEED_CROP_RATE        @"cropRate"
#define PARSE_FEED_LOCATION         @"location"
#define PARSE_FEED_ON_STAMP         @"stamp_on"
#define PARSE_FEED_FLAG             @"flagged"
#define PARSE_FEED_BANNED           @"banned"
#define PARSE_FEED_CLEAND           @"cleaned"
#define PARSE_FEED_VIDEO            @"video"

// comment table
#define PARSE_TABLE_COMMENT         @"Comment"
#define PARSE_COMMENT_FEED          @"feed"
#define PARSE_COMMENT_TEXT          @"comment"
#define PARSE_COMMENT_LIKES         @"likes"
#define PARSE_COMMENT_DISLIKES      @"dislikes"

// follow table
#define PARSE_TABLE_FOLLOW          @"Follow"
#define PARSE_FOLLOW_USER           @"user"
#define PARSE_FOLLOW_FOLLOWING      @"following"

// news Table
#define PARSE_TABLE_NEWS            @"News"
#define PARSE_NEWS_USER             @"user"
#define PARSE_NEWS_POSTER           @"poster"
#define PARSE_NEWS_TYPE             @"type"
#define PARSE_NEWS_FEED             @"feed"

// comment table
#define PARSE_TABLE_STAMP           @"Stamp"
#define PARSE_STAMP_USER            @"user"
#define PARSE_STAMP_TEXT            @"text"
#define PARSE_STAMP_FONTTYPE        @"fonttype"
#define PARSE_STAMP_FONTCOLOR       @"fontcolor"
#define PARSE_STAMP_FEED            @"feed"
#define PARSE_STAMP_LOCATION        @"location"
#define PARSE_STAMP_FILE            @"stamp"
enum {
    NEWS_COMMENT = 1000,
    NEWS_LIKED,
    NEWS_FOLLOWING
};

// Hashtag Table
#define PARSE_TABLE_HASHTAG         @"HashTags"
#define PARSE_HASHTAG_TAG           @"tag"

enum {
    CAMERA_STATE_NONE = -1,
    CAMERA_TAKE_PHOTO = 1000,
    CAMERA_CHOOSE_MEDIA,
    CAMERA_SET_FILTER,
    CAMERA_CROP_IMAGE,
};

enum {
    CROP_1_1 = 11,
    CROP_4_3 = 43,
    CROP_3_4 = 34,
};



#define SCREEN_SIZE                 [UIScreen mainScreen].bounds.size
#define SCREEN_WIDTH                [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT               [UIScreen mainScreen].bounds.size.height

#define COLOR_BLUE_LIGHT            [UIColor colorWithRed:16/255.0 green:151/255.0 blue:1.0 alpha:1.0]
#define COLOR_BLUE                  [UIColor colorWithRed:24/255.0 green:48/255.0 blue:88/255.0 alpha:1.0]
#define COLOR_BLUE_DARK             [UIColor colorWithRed:16/255.0 green:27/255.0 blue:47/255.0 alpha:1.0]
#define COLOR_GREEN                 [UIColor colorWithRed:89/255.0 green:191/255.0 blue:49/255.0 alpha:1.0]
#define COLOR_ORANGE                [UIColor colorWithRed:1.0 green:82/255.0 blue:16/255.0 alpha:1.0]

#define COLOR_YELLOW                [UIColor colorWithRed:254/255.0 green:188/255.0 blue:17/255.0 alpha:1.0]
#define COLOR_YELLOW_               [UIColor colorWithRed:254/255.0 green:188/255.0 blue:17/255.0 alpha:1.0]
#define COLOR_GRAY_DARK             [UIColor colorWithRed:109/255.0 green:110/255.0 blue:113/255.0 alpha:1.0]
#define COLOR_GRAY_LIGHT            [UIColor colorWithRed:147/255.0 green:149/255.0 blue:152/255.0 alpha:1.0]

/* ***************** animation time relation *********************/
#define TIME_ANIMATION_SHORT        0.3
#define TIME_ANIMATION_DEFAULT      0.6
#define TIME_ANIMATION_LONG         2.0

/* ***************** Photo size relation *********************/
#define IMAGE_SIZE_VERY_SMALL       64.0
#define IMAGE_SIZE_SMALL            128.0
#define IMAGE_SIZE_NORMAL           256.0
#define IMAGE_SIZE_LARGE            512.0
#define IMAGE_SIZE_VERY_LARGE       1024.0
#define IMAGE_SIZE_STAMP            335.0

#define IMAGE_WIDTH_HEIGHT_RATE     1936.00/2592.0

/* ******************** Notification *************************/
#define NOTIFICATION_CONTROLLER_POPUP       @"NOTIFICATION_CONTROLLER_POPUP"
#define NOTIFICATION_FOLLOWINGS_CHANGED     @"NOTIFICATION_FOLLOWINGS_CHANGED"
#define NOTIFICATION_UNFOLLOWINGS_CHANGED   @"NOTIFICATION_UNFOLLOWINGS_CHANGED"
#define NOTIFICATION_DETAIL_LIKE            @"NOTIFICATION_DETAIL_LIKE"
#define NOTIFICATION_TABBAR_CHANGED         @"NOTIFICATION_TABBAR_CHANGED"
#define NOTIFICATION_LET_ME_SEE             @"NOTIFICATION_LET_ME_SEE"
#define SELECTED_TAB_INDEX                  @"selected_index"


#define QUERY_MAX_LIMIT                 1000

#define TAG_ERROR                       -1
#define TAG_SUCCESS                     1
#define TAG_EMAIL                       100
#define TAG_NOTE                        101
#define TAG_DELETE                      102
#define TAG_EDIT                        103
#define TAG_PASSWORD_RESET              200

/* location */
#define kGeoCodingString @"http://maps.google.com/maps/geo?q=%f,%f&output=csv"
#define kGeoLatitude @"latitude"
#define kGeoLongitude @"longitude"

/* Twitter */
#define TWITTER_CONSUMER_KEY                @"lHJ9hhJVsnhOBeavbN91melTy"
#define TWITTER_SECRET_KEY                  @"wDGGuKeMchMYjX0lz3xPTWbMFBvFAlXuAEcops2Cuawsrl9VBc"
#define TWITTER_AUTHORISED                  @"authorized"
#define TWITTER_LOGGED_IN                   @"Twitter"

/* Facebook */
#define FACEBOOK_LOGGED_IN                  @"Facebook"

/* Delivery Address */
#define ADDRESS_FIRST_NAME                  @"address_first_name"
#define ADDRESS_LAST_NAME                   @"address_last_name"
#define ADDRESS_COUNTRY                     @"address_country"
#define ADDRESS_STREET                      @"address_street"
#define ADDRESS_CITY                        @"address_city"
#define ADDRESS_POST_CODE                   @"address_post_code"
#define ADDRESS_PHONE                       @"address_phone"

typedef void (^callbackAPI)(BOOL, id);

extern NSString *const StripePublishableKey;
extern NSString *const BackendChargeURLString;

NSString *localization;

double longitude;
double latitude;

DeliveryAndBillingModel *model;

@interface AppConfig : NSObject

+ (void)setStringValueForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)getStringValueForKey:(NSString *)key;

+ (void)setBoolValueForKey:(NSString *)key value:(BOOL)value;
+ (BOOL)getBoolValueForKey:(NSString *)key;
+ (NSString *)getAddressFromLatLon;

+ (void)setDeliveryModel:(DeliveryAndBillingModel *) model;
+ (DeliveryAndBillingModel *) getDeliveryModel;

typedef void(^addressCompletion)(NSString *);
+(void)getAddressFromLocation:(CLLocation *)location complationBlock:(addressCompletion)completionBlock;
+(NSString *) getLocalization;
@end
