//
//  ProfileViewController.m
//  SportWorldPassport
//
//  Created by star on 1/26/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "ProfileViewController.h"
#import "FeedDetailViewController.h"
#import "UserOperationViewController.h"
#import "FeedCell.h"
#import "UIImage+Convenience.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, FeedCellDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnFollow;
    IBOutlet CircleImageView *avatarImageView;
    IBOutlet UILabel *lblFullName;
    IBOutlet UILabel *lblUsername;
    IBOutlet UILabel *lblDescription;
    IBOutlet UILabel *lblPostCounts;
    IBOutlet UILabel *lblFollowers;
    IBOutlet UILabel *lblFollowings;
    IBOutlet UITableView *feedTableView;
    IBOutlet UIButton *btnOperation;
    
    NSIndexPath *currentIndex;
    NSMutableArray *feedArray;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onFollow:(id)sender;

@end


@implementation ProfileViewController

@synthesize user;
@synthesize isFollowed;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [user fetchIfNeeded];
    // set profile data
    [ParseUtils setParsePictureOf:avatarImageView file:user[PARSE_USER_AVATAR] default:nil];
    lblFullName.text = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTNAME]];
    lblTitle.text = user.username;
    lblUsername.text = [NSString stringWithFormat:@"@%@", user.username];
    lblPostCounts.text = [NSString stringWithFormat:@"%d", [user[PARSE_USER_POST_COUNT] intValue]];
    
    feedArray = [[NSMutableArray alloc] init];
    
    if (isFollowed) {
        [btnFollow setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
    } else {
        [btnFollow setTitle:@"FOLLOW" forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]){
        btnFollow.hidden = YES;
        btnOperation.hidden = YES;
    } else {
        btnFollow.hidden = NO;
        btnOperation.hidden = NO;
    }
    
    [self loadFeedData];
}

- (void)loadFeedData {
    // fetch post data
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
    [query whereKey:PARSE_FIELD_USER equalTo:user];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [query includeKey:PARSE_FIELD_USER];
    [query setLimit:QUERY_MAX_LIMIT];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects) {
            feedArray = [[NSMutableArray alloc] initWithArray:objects];
            [feedTableView reloadData];
        }
    }];
    
    PFQuery *postQuery = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
    [postQuery whereKey:PARSE_FIELD_USER equalTo:user];
   
    [postQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            int postCount = [user[PARSE_USER_POST_COUNT] intValue];
            if (number != postCount) {
                lblPostCounts.text = [NSString stringWithFormat:@"%d", number];
//                user[PARSE_USER_POST_COUNT] = [NSNumber numberWithInt:number];
//                [user saveInBackground];
            }
        }
    }];
    
    // fetch following counts and follower counts
    PFQuery *followerQuery = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [followerQuery whereKey:PARSE_FIELD_USER equalTo:user];
    [followerQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            lblFollowers.text = [NSString stringWithFormat:@"%d", number];
        }
    }];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [followingQuery whereKey:PARSE_FOLLOW_FOLLOWING equalTo:user];
    [followingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            lblFollowings.text = [NSString stringWithFormat:@"%d", number];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return feedArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    
    PFObject *feed = feedArray[indexPath.row];
    
    [cell setData:feed];
    cell.delegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 170.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndex = indexPath;
    
    FeedDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedDetailViewController"];
    vc.feedObject = feedArray[indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma feedCell delegate
- (void)onLikeFeed:(FeedCell *)cell liked:(BOOL)liked {
    NSIndexPath *indexPath = [feedTableView indexPathForCell:cell];
    
    // show result before save
    int likeCount = [cell.lblLikeCount.text intValue];
    
    [cell.btnLike setSelected:!liked];
    if (liked) {
        [cell.lblLikeCount setText:[NSString stringWithFormat:@"%d", likeCount - 1]];
    } else {
        [cell.lblLikeCount setText:[NSString stringWithFormat:@"%d", likeCount + 1]];
    }
    // save
    PFObject *feed = feedArray[indexPath.row];
    [ParseUtils likeFeed:feed like:!liked withView:self.view];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onReportUser:(id)sender {
    UserOperationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserOperationViewController"];
    vc.bgImage = [UIImage imageWithView:self.view];
    vc.user = user;
    vc.isBlocking = YES;
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)onFollow:(id)sender {
    if (!isFollowed) {
        [btnFollow setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
        PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_FOLLOW];
        object[PARSE_FOLLOW_USER] = user;
        object[PARSE_FOLLOW_FOLLOWING] = [PFUser currentUser];
        [object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            if (!error && succeed){
                [self sendPush:NO];
            }
        }];
        
        if (![user.objectId isEqualToString:[PFUser currentUser].objectId]){
            PFObject *news = [PFObject objectWithClassName:PARSE_TABLE_NEWS];
            news[PARSE_NEWS_USER] = user;
            news[PARSE_NEWS_POSTER] = [PFUser currentUser];
            news[PARSE_NEWS_TYPE] = [NSNumber numberWithInt:NEWS_FOLLOWING];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [news saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }

    } else {
        [btnFollow setTitle:@"FOLLOW" forState:UIControlStateNormal];
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
        [query whereKey:PARSE_FOLLOW_USER equalTo:user];
        [query whereKey:PARSE_FOLLOW_FOLLOWING equalTo:[PFUser currentUser]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [object deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                if (!error && succeed){
                    [self sendPush:YES];
                }
            }];
        }];
    }
    isFollowed = !isFollowed;
}
- (void) sendPush:(BOOL) isFollow
{
    NSString *msg = @"";
    if (isFollowed){ // unfollow user
        msg = [NSString stringWithFormat:@"%@ followed you.", [PFUser currentUser].username];
    } else { // follow user
        msg = [NSString stringWithFormat:@"%@ unfollowed you.", [PFUser currentUser].username];
    }
    
    PFQuery *followQuery = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [followQuery whereKey:PARSE_FOLLOW_USER equalTo:user];
    [followQuery includeKey:PARSE_FOLLOW_USER];
    [followQuery setLimit:QUERY_MAX_LIMIT];
    [followQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error){
        if (!error && object){
            //            PFQuery *pushQuery = [PFInstallation query];
            //            [pushQuery whereKey:PARSE_FIELD_USER containedIn:[NSArray arrayWithObject:object[PARSE_FOLLOW_USER]]];
            //            NSDictionary *data = @{
            //                                   @"alert" : msg,
            //                                   @"badge" : @"Increment",
            //                                   @"sounds" : @"cheering.caf",
            //                                   @"type"  : @"feed"
            //                                   };
            PFUser *receiver = (PFUser *) object[PARSE_FOLLOW_USER];
            NSDictionary *params = @{
                                     @"alert" : msg,
                                     @"type"  : @"feed",
                                     @"badge" : @"increment",
                                     @"sound" : @"cheering.caf",
                                     @"idlist" : [NSArray arrayWithObject:receiver.objectId]
                                     };
            //            PFPush *push = [[PFPush alloc] init];
            //            [push setQuery:pushQuery];
            //            [push setData:data];
            //            [push sendPushInBackground];
            
            [PFCloud callFunctionInBackground:@"SendPush" withParameters:params block:^(NSString* result, NSError *error){
                if (error){
                    NSLog(@"%@", error);
                }
            }];
        }
    }];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

}

@end
