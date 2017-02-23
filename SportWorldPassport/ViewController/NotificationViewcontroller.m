//
//  NotificationViewcontroller.m
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "NotificationViewcontroller.h"

#import "NotificationCell.h"
#import "AAPullToRefresh.h"
#import "FeedDetailViewController.h"
#import "CommonUtils.h"
#import "ProfileViewController.h"

@interface NotificationViewcontroller() <UITableViewDataSource, UITableViewDelegate, NewsCellDelegate>
{
    IBOutlet UILabel *noNotificationLabel;
    IBOutlet UITableView *notTableView;
    
    NSMutableArray *notArray;
    NSMutableArray *commentArray;
    NSIndexPath *currentIndex;
    
    BOOL mInitialized;
    
    AAPullToRefresh *topRefreshView;
}
@end

@implementation NotificationViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    notArray = [[NSMutableArray alloc] init];
    commentArray = [[NSMutableArray alloc] init];
    
    __weak typeof(self) weakSelf = self;
    topRefreshView = [notTableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v){
        [weakSelf refreshItems];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    topRefreshView.showPullToRefresh = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    topRefreshView.showPullToRefresh = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    if (!mInitialized) {
        mInitialized = YES;
        [topRefreshView manuallyTriggered];
//    }
}

- (void)refreshItems {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NEWS];
    [query whereKey:PARSE_NEWS_USER equalTo:[PFUser currentUser]];
    [query includeKey:PARSE_NEWS_FEED];
    [query includeKey:PARSE_NEWS_POSTER];
    [query setLimit:QUERY_MAX_LIMIT];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [notArray removeAllObjects];
        [commentArray removeAllObjects];
        
        if (!error && objects.count > 0) {
            notArray = [[NSMutableArray alloc] initWithArray:objects];
            [topRefreshView performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:0.1f];
            [notTableView reloadData];
        } else {
            [topRefreshView performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:0.1f];
            [notTableView reloadData];
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (notArray.count > 0) {
        [noNotificationLabel setHidden:YES];
    } else {
        [noNotificationLabel setHidden:NO];
    }
    return notArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notifCell"];
    PFObject *object = notArray[indexPath.row];
    
    //manage comments array
    if ([object[PARSE_NEWS_TYPE] intValue] == NEWS_COMMENT){
        [commentArray addObject:notArray[indexPath.row]];
    }
    
    [cell setData:object];
    cell.delegate = self;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndex = indexPath;
    
    PFObject *obj = notArray[indexPath.row];
    int type = [obj[PARSE_NEWS_TYPE] intValue];
    if (type == NEWS_COMMENT){
            FeedDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedDetailViewController"];
            
            PFObject *feed = obj[PARSE_NEWS_FEED];
            if (!feed){
                [CommonUtils showAlertView:@"Error" message:@"File Not exist on Server!" delegate:self tag:TAG_ERROR];
                return;
            }
            
            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
            [query whereKey:PARSE_FIELD_OBJECT_ID equalTo:feed.objectId];
            [query includeKey:PARSE_FIELD_USER];
        
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (object && !error){
                    vc.feedObject = object;
                    
                    NSMutableArray *temp = [[NSMutableArray alloc] init];
                    for (PFObject *single in notArray){
                        PFObject *objId = single[PARSE_NEWS_FEED];
                        
                        if ([objId.objectId isEqualToString:object.objectId]){
                            [temp addObject:single];
                        }
                    }
                    NSUInteger index = [temp indexOfObject:obj];
                    vc.index = index;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
    } else if (type == NEWS_LIKED){
        PFObject *feed = obj[PARSE_NEWS_FEED];
        if (!feed){
            [CommonUtils showAlertView:@"Error" message:@"File Not exist on Server!" delegate:self tag:TAG_ERROR];
            return;
        }
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
        [query whereKey:PARSE_FIELD_OBJECT_ID equalTo:feed.objectId];
        [query includeKey:PARSE_FIELD_USER];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (object && !error){
                FeedDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedDetailViewController"];
                vc.feedObject = object;
                vc.index = -1;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    } else if (type == NEWS_FOLLOWING){
        PFUser *poster = obj[PARSE_NEWS_POSTER];
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
        [query whereKey:PARSE_FOLLOW_USER equalTo:poster];
        [query whereKey:PARSE_FOLLOW_FOLLOWING equalTo:[PFUser currentUser]];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            BOOL isFollowed = NO;
            if (!error && object) {
                isFollowed = YES;
            }
            ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            vc.user = poster;
            vc.isFollowed = isFollowed;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
}

#pragma notification cell delegate
- (void)onSeeNews:(NotificationCell *)cell {
    
}

@end
