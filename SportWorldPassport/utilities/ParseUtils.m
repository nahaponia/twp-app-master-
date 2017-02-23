//
//  ParseUtils.m
//  SportWorldPassport
//
//  Created by star on 10/30/15.
//  Copyright (c) 2015 com.UWP. All rights reserved.
//

#import "ParseUtils.h"
#import "NSDate/NSDate+Convenience.h"

@implementation ParseUtils

+ (void)setParsePictureOf:(UIImageView *)imageView file:(PFFile *)pFile default:(NSString *)name {
    
    if (pFile) {
        UIActivityIndicatorView *waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [waitView hidesWhenStopped];
        CGSize imageSize = imageView.frame.size;
        CGSize aSize = waitView.frame.size;
        [waitView setFrame:CGRectMake((imageSize.width - aSize.width) / 2.0, (imageSize.height - aSize.height) / 2.0, aSize.width, aSize.height)];
        [imageView addSubview:waitView];
        [waitView startAnimating];
        [pFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [waitView stopAnimating];
            [waitView removeFromSuperview];
            
            [imageView setImage:[UIImage imageWithData:data]];
        }];
    } else if (name && name.length > 0) {
        [imageView setImage:[UIImage imageNamed:name]];
    } else {
        [imageView setImage:[[UIImage alloc] init]];
    }
}

+ (void)likeFeed:(PFObject *)feed like:(BOOL)like withView:(UIView *) view {
    NSMutableArray *likers = feed[PARSE_FEED_LIKES];
    
    if (like) {
        [likers addObject:[PFUser currentUser].objectId];
        
        PFUser *poster = feed[PARSE_FIELD_USER];
        if (![poster.objectId isEqualToString:[PFUser currentUser].objectId]){
            PFObject *news = [PFObject objectWithClassName:PARSE_TABLE_NEWS];
            news[PARSE_NEWS_FEED] = feed;
            news[PARSE_NEWS_USER] = poster;
            news[PARSE_NEWS_POSTER] = [PFUser currentUser];
            news[PARSE_NEWS_TYPE] = [NSNumber numberWithInt:NEWS_LIKED];
            [MBProgressHUD showHUDAddedTo:view animated:YES];
            [news saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideHUDForView:view animated:YES];
            }];
        }
    } else {
        [likers removeObject:[PFUser currentUser].objectId];
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NEWS];
        [query whereKey:PARSE_NEWS_USER equalTo:feed[PARSE_FIELD_USER]];
        [query whereKey:PARSE_NEWS_POSTER equalTo:[PFUser currentUser]];
        [query whereKey:PARSE_NEWS_FEED equalTo:feed];
        [query whereKey:PARSE_NEWS_TYPE equalTo:[NSNumber numberWithInt:NEWS_LIKED]];
        [MBProgressHUD showHUDAddedTo:view animated:YES];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [MBProgressHUD hideHUDForView:view animated:YES];
            if (object) {
                [object deleteInBackground];
            }
        }];
        
    }
    
    feed[PARSE_FEED_LIKES] = likers;
    [feed saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [feed fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            }];
        }
    }];
}

+ (void)sendParseEmail:(NSString *)to from:(NSString *)from message:(NSString *)message {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:to forKey:@"toEmail"];
    [dic setValue:from forKey:@"fromEmail"];
    [dic setValue:message forKey:@"text"];
    [dic setValue:@"Invitation to TravelWorldPassport" forKey:@"subject"];
    
    [PFCloud callFunctionInBackground:@"sendEmailTemplate" withParameters:dic block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"error happened in Mail sending: %@", error.description);
        } else {
            NSLog(@"Sending mail successfully");
        }
    }];
}

+ (void)sendParseEmailWithTemplate:(NSString *)templateName to:(NSString *)to from:(NSString *)from message:(NSDictionary *)message {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:message];
    [dic setValue:to forKey:@"toEmail"];
    [dic setValue:from forKey:@"fromEmail"];
    [dic setValue:@"Invitation to TravelWorldPassport" forKey:@"subject"];
    
    [PFCloud callFunctionInBackground:@"sendEmailTemplate" withParameters:dic block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"error happened in Mail sending: %@", error.description);
        } else {
            NSLog(@"Sending mail successfully");
        }
    }];
    
}

+ (void)sendPushOfShow:(PFObject *)showObject from:(NSDate *)date {
    /*
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query whereKey:PARSE_FOLLOW_FIELD_ARTIST equalTo:[PFUser currentUser]];
    if (date) {
        [query whereKey:PARSE_FIELD_CREATED_AT greaterThan:date];
    }
    [query orderByAscending:PARSE_FIELD_CREATED_AT];
    [query includeKey:PARSE_FOLLOW_FIELD_FOLLOWER];
    [query setLimit:QUERY_MAX_LIMIT];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count > 0) {
            NSMutableArray *userArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < objects.count; i++) {
                PFObject *object = objects[i];
                PFUser *user = object[PARSE_FOLLOW_FIELD_FOLLOWER];
                if ([user[PARSE_USER_FIELD_NOTIFICATION] boolValue]) {
                    [userArray addObject:user];
                }
            }
            
            if (userArray.count > 0) {
                NSString *alert = [NSString stringWithFormat:@"%@ just added a new show.\n %@ on %@ at %@", [PFUser currentUser].username, showObject[PARSE_SHOW_FIELD_ADDRESS], [NSDate stringFromDate:showObject[PARSE_SHOW_FIELD_START_TIME] format:@"MMMM dd"], [NSDate stringFromDate:showObject[PARSE_SHOW_FIELD_START_TIME] format:@"hh:mm a"]];
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:PARSE_FIELD_USER containedIn:userArray];
                
                // Send push notification to query
                NSDictionary *data = @{
                                       @"alert" : alert,
                                       @"badge" : @"Increment",
                                       @"sounds" : @"cheering.caf"
                                       };
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                [push setData:data];
                [push sendPushInBackground];
            }
            
            PFObject *lastObject = [objects lastObject];
            [ParseUtils sendPushOfShow:showObject from:lastObject.createdAt];
        }
    }];
    */
}




@end
