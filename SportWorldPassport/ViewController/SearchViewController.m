//
//  SearchViewController.m
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "SearchViewController.h"
#import "MainViewController.h"
#import "ProfileViewController.h"
#import "FeedDetailViewController.h"
#import "AAPullToRefresh.h"
#import "AppDataManager.h"
#import "CommonUtils.h"

#import "FeedCell.h"
#import "ParseUtils.h"
#import "HTHorizontalSelectionList.h"
#import "ToastView.h"

#define TOP_BAR_HEIGHT          46
#define STATUS_BAR_HEIGHT       20

@interface SearchViewController() <UITableViewDataSource, UITableViewDelegate, FeedCellDelegate, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource> {

    int topbarIndex;
    BOOL isFollowed;
    NSIndexPath *currentIndex;
    NSMutableArray *momentArray;
    NSMutableArray *hashtagArray;
    NSMutableArray *userArray;
    NSMutableArray *labelMakes;
    
    BOOL momentInitialized;
    BOOL hashtagInitialized;
    BOOL userInitialized;
    
    AAPullToRefresh *momentRefreshView;
    AAPullToRefresh *hashTagRefreshView;
    AAPullToRefresh *userRefreshView;
    
    IBOutlet UITextField *txtSearch;
    IBOutlet UIView *showTrendingView;
    IBOutlet UITableView *userTableView;
    IBOutlet UITableView *hashtagTableView;
    IBOutlet UITableView *momentTableView;
    
    IBOutlet UIView *topBarView;
    
}

@property (nonatomic, strong) HTHorizontalSelectionList *topbarList;

- (IBAction)onSearch:(id)sender;
- (IBAction)onSeeTrending:(id)sender;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // array of data
    momentArray = [[NSMutableArray alloc] init];
    hashtagArray = [[NSMutableArray alloc] init];
    userArray = [[NSMutableArray alloc] init];
       
    [self initTopBar];
    
    // refresh views
    __weak typeof(self) weakSelf = self;
    momentRefreshView = [momentTableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v){
        [weakSelf refreshItems];
    }];
    hashTagRefreshView = [hashtagTableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v){
        [weakSelf refreshItems];
    }];
    userRefreshView = [userTableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v){
        [weakSelf refreshItems];
    }];
}

- (void)initTopBar {
    topbarIndex = 0;
    labelMakes = [[NSMutableArray alloc] initWithObjects:@"EXPERIENCE", @"HASHTAG", @"USER", nil];
    
    self.topbarList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, TOP_BAR_HEIGHT)];
    self.topbarList.delegate = self;
    self.topbarList.dataSource = self;
    self.topbarList.backgroundColor = [UIColor clearColor];
    
    self.topbarList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.topbarList.selectionIndicatorColor = COLOR_BLUE_LIGHT;
    
    [self.topbarList setTitleColor:COLOR_BLUE_LIGHT forState:UIControlStateHighlighted];
    [self.topbarList setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.topbarList setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateNormal];
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateSelected];
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateHighlighted];
    
    [topBarView addSubview:self.topbarList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // default setting of refresh view
    momentRefreshView.showPullToRefresh = YES;
    hashTagRefreshView.showPullToRefresh = YES;
    userRefreshView.showPullToRefresh = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // default setting of refresh view
    momentRefreshView.showPullToRefresh = NO;
    hashTagRefreshView.showPullToRefresh = NO;
    userRefreshView.showPullToRefresh = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![showTrendingView isHidden]) {
        if (!momentInitialized && topbarIndex == 0) {
            [momentRefreshView manuallyTriggered];
            momentInitialized = YES;
        } else if (!hashtagInitialized && topbarIndex == 1) {
            [hashTagRefreshView manuallyTriggered];
            hashtagInitialized = YES;
        } else if (!userInitialized && topbarIndex == 2) {
            [userRefreshView manuallyTriggered];
            userInitialized = YES;
        }
    }
    
    [self refreshItems];
}

- (IBAction)onSearch:(id)sender {
    NSString *searchString = [txtSearch.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([searchString isEqualToString:@""]) {
        [showTrendingView setHidden:NO];
        return;
    }
    
    [showTrendingView setHidden:YES];
    
    if (topbarIndex == 0) {
        [momentRefreshView manuallyTriggered];
    } else if (topbarIndex == 1) {
        [hashTagRefreshView manuallyTriggered];
    } else if (topbarIndex == 2) {
        [userRefreshView manuallyTriggered];
    }
}

- (IBAction)onSeeTrending:(id)sender {
//    [[MainViewController getInstance] selectTabbar:TAB_FEED];
    [[MainViewController getInstance] gotoTrendingView];
}

- (void)refreshItems {
    NSString *searchString = [txtSearch.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([searchString isEqualToString:@""]) {
        [momentRefreshView performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:0.1f];
        return;
    }
    
    switch (topbarIndex) {
        case 0:
        {
            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
            [query whereKey:PARSE_FEED_TITLE matchesRegex:searchString modifiers:@"i"];
            [query whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
            [query whereKey:PARSE_FIELD_USER notContainedIn:[AppDataManager instance].bannedArray];
            [query whereKey:PARSE_FIELD_USER notContainedIn:[AppDataManager instance].blockedArray];
            [query includeKey:PARSE_FIELD_USER];
            [query orderByDescending:PARSE_FIELD_CREATED_AT];
            [query setLimit:QUERY_MAX_LIMIT];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
                if (!error) {
                    momentArray = [[NSMutableArray alloc] initWithArray:objs];
                }
                if (!momentRefreshView.isHidden && topbarIndex == 0) {
                    [momentRefreshView performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:0.1f];
                    [momentTableView reloadData];
                }
            }];
        }
            break;
        case 1:
        {
            NSString *tagStr = [searchString stringByReplacingOccurrencesOfString:@"#" withString:@""];
            tagStr = [NSString stringWithFormat:@"#%@", tagStr];
//            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_HASHTAG];
//            [query whereKey:PARSE_HASHTAG_TAG matchesRegex:tagStr modifiers:@"i"];
//            [query orderByAscending:PARSE_HASHTAG_TAG];
//            [query setLimit:QUERY_MAX_LIMIT];

            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
            [query whereKey:PARSE_FEED_TAGS containsString:tagStr];
            [query includeKey:PARSE_FIELD_USER];
            [query orderByAscending:PARSE_HASHTAG_TAG];
            [query setLimit:QUERY_MAX_LIMIT];

            [query findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
                if (!error) {
                    hashtagArray = [[NSMutableArray alloc] initWithArray:objs];  // feed array
                }
                if (!hashTagRefreshView.isHidden && topbarIndex == 1) {
                    [hashTagRefreshView performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:0.1f];
                    [hashtagTableView reloadData];
                }
            }];
        }
            break;
        case 2:
        {
            PFQuery *query = [PFUser query];
            [query whereKey:PARSE_USER_USERNAME matchesRegex:searchString modifiers:@"i"];
            [query whereKey:PARSE_FIELD_OBJECT_ID notEqualTo:[PFUser currentUser].objectId];
            [query whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
            [query whereKey:PARSE_FIELD_OBJECT_ID notContainedIn:[AppDataManager instance].blockdedIdArray];
            [query setLimit:QUERY_MAX_LIMIT];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
                if (!error) {
                    userArray = [[NSMutableArray alloc] initWithArray:objs];
                }
                if (!userRefreshView.isHidden && topbarIndex == 2) {
                    [userRefreshView performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:0.1f];
                    [userTableView reloadData];
                }
            }];
        }
        default:
            break;
    }
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods
- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return labelMakes.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    return labelMakes[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods
- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    if (topbarIndex != index) {
        topbarIndex = index;
        if (topbarIndex == 0) {
            [momentTableView setHidden:NO];
            [hashtagTableView setHidden:YES];
            [userTableView setHidden:YES];
            
            if (!momentInitialized) {
                [momentRefreshView manuallyTriggered];
                momentInitialized = YES;
            }
        } else if (topbarIndex == 1) {
            [momentTableView setHidden:YES];
            [hashtagTableView setHidden:NO];
            [userTableView setHidden:YES];
            
            if (!hashtagInitialized) {
                [hashTagRefreshView manuallyTriggered];
                hashtagInitialized = YES;
            }
        } else if (topbarIndex == 2) {
            [momentTableView setHidden:YES];
            [hashtagTableView setHidden:YES];
            [userTableView setHidden:NO];
            
            if (!userInitialized) {
                [userRefreshView manuallyTriggered];
                userInitialized = YES;
            }
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == momentTableView) {
        if (showTrendingView.isHidden && momentArray.count == 0){
            [ToastView showToast:@" No result for your search " durationTime:2];
        }
        return momentArray.count;
    } else if (tableView == hashtagTableView) {
        if (showTrendingView.isHidden && hashtagArray.count == 0){
            [ToastView showToast:@" No result for your search " durationTime:2];
        }
        return hashtagArray.count;
    } else { // userTableView
        if (showTrendingView.isHidden && userArray.count == 0){
            [ToastView showToast:@" No result for your search " durationTime:2];
        }
        return userArray.count;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (tableView == momentTableView) {
        FeedCell *feedCell = [tableView dequeueReusableCellWithIdentifier:@"followedCell"];
        PFObject *feed = momentArray[indexPath.row];
        [feedCell setData:feed];
        feedCell.delegate = self;
        cell = feedCell;
    } else if (tableView == hashtagTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"hashtagCell"];
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        PFObject *hashtag = hashtagArray[indexPath.row];
        label.text = hashtag[PARSE_FEED_TAGS];
    } else { // userTableView
        cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
        UIImageView *avatar = (UIImageView *)[cell viewWithTag:100];
        UILabel *lblName = (UILabel *)[cell viewWithTag:101];
        UILabel *lblFullName = (UILabel *)[cell viewWithTag:102];

        PFUser *user = userArray[indexPath.row];
        [ParseUtils setParsePictureOf:avatar file:user[PARSE_USER_AVATAR] default:nil];
        lblName.text = user.username;
        lblFullName.text = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTNAME]];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == momentTableView) {
        return 170.0;
    } else if (tableView == hashtagTableView) {
        return 44.0;
    } else { // userTableView
        return 56.0;
    }
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndex = indexPath;
    if (tableView == momentTableView) {
        FeedDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedDetailViewController"];
        vc.feedObject = momentArray[indexPath.row];
        
        [self.navigationController pushViewController:vc animated:YES];
    } else if (tableView == hashtagTableView) {
        PFObject *hashtag = hashtagArray[indexPath.row];
        if ([[hashtag[PARSE_FEED_BANNED] lowercaseString] isEqualToString:@"true"]){
            [CommonUtils showAlertView:@"Error" message:@"This moment is banned!" delegate:self tag:TAG_ERROR];
        } else {
            FeedDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedDetailViewController"];
            vc.feedObject = hashtag;
            [self.navigationController pushViewController:vc animated:YES];
        }

//        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
//        [query whereKey:PARSE_FEED_TAGS equalTo:hashtag[PARSE_HASHTAG_TAG]];
////        [query whereKey:PARSE_FEED_TAGS containsString:hashtag[PARSE_HASHTAG_TAG]];
////        [query whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
////        [query whereKey:PARSE_FIELD_USER notContainedIn:[AppDataManager instance].bannedArray];
////        [query whereKey:PARSE_FIELD_USER notContainedIn:[AppDataManager instance].blockedArray];
//        [query includeKey:PARSE_FIELD_USER];
//        [query orderByDescending:PARSE_FIELD_CREATED_AT];
//        [query setLimit:QUERY_MAX_LIMIT];
//        
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            
//            if (object){
//                
//                if ([object[PARSE_FEED_BANNED] isEqualToString:@"true"]){
//                    [CommonUtils showAlertView:@"Error" message:@"This moment is banned!" delegate:self tag:TAG_ERROR];
//                } else {
//                    vc.feedObject = object;
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//            } else {
//                [CommonUtils showAlertView:@"Error" message:@"No moment exists!" delegate:self tag:TAG_ERROR];
//            }
//        }];
        
    } else { // userTableView
        PFUser *user = userArray[indexPath.row];
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
        [query whereKey:PARSE_FOLLOW_USER equalTo:user];
        [query whereKey:PARSE_FOLLOW_FOLLOWING equalTo:[PFUser currentUser]];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            isFollowed = NO;
            if (!error && object) {
                isFollowed = YES;
            }
            
            ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            vc.user = user;
            vc.isFollowed = isFollowed;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
}

#pragma feedCell delegate
- (void)onLikeFeed:(FeedCell *)cell liked:(BOOL)liked {
    NSIndexPath *indexPath = [momentTableView indexPathForCell:cell];
    PFObject *feed = momentArray[indexPath.row];
    NSMutableArray *likers = feed[PARSE_FEED_LIKES];
    
    // save liked data after display result
    int likeCount = [cell.lblLikeCount.text intValue];
    
    [cell.btnLike setSelected:!liked];
    if (liked) {
        [likers removeObject:[PFUser currentUser].objectId];
        [cell.lblLikeCount setText:[NSString stringWithFormat:@"%d", likeCount - 1]];
    } else {
        [likers addObject:[PFUser currentUser].objectId];
        [cell.lblLikeCount setText:[NSString stringWithFormat:@"%d", likeCount + 1]];
    }
    
    feed[PARSE_FEED_LIKES] = likers;
    [feed saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [feed fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            }];
        }
    }];
}

#pragma textfield delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"profileSegue"]) {
        PFUser *user = userArray[currentIndex.row];
        ProfileViewController *vc = segue.destinationViewController;
        vc.user = user;
        vc.isFollowed = isFollowed;
    }
}

@end
