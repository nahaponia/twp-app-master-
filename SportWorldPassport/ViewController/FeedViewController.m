//
//  FeedViewController.m
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedDetailViewController.h"
#import "AppDataManager.h"

#import "FeedCell.h"
#import "ParseUtils.h"

#import "HTHorizontalSelectionList.h"
#import "LoginViewController.h"
#import "MainViewController.h"

#define TOP_BAR_HEIGHT          46
#define STATUS_BAR_HEIGHT       20

@interface FeedViewController () <UITableViewDataSource, UITableViewDelegate, FeedCellDelegate, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource, UIScrollViewDelegate> {
    
    NSIndexPath *currentIndex;
    NSMutableArray *followedArray;
    NSMutableArray *trendingArray;
    NSMutableArray *labelMakes;
    NSMutableArray *blockArray;
    
    BOOL mFollowedInitialized;
    BOOL mTrendingInitialized;
    
    UIRefreshControl *refreshControl;
    
    IBOutlet UIView *topBarView;
    IBOutlet UITextView *txtNoFollowed;
}

@property (nonatomic, strong) HTHorizontalSelectionList *topbarList;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FeedViewController
bool isRefreshing = false;
bool isFromDetail = false;

@synthesize topbarIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    followedArray = [[NSMutableArray alloc] init];
    trendingArray = [[NSMutableArray alloc] init];
    blockArray = [[NSMutableArray alloc] init];
    
    [self initTopBar];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = COLOR_BLUE;
    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoTrendingView:)
                                                 name:NOTIFICATION_LET_ME_SEE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likedInDetail:) name:NOTIFICATION_DETAIL_LIKE object:nil];

}

- (void)initTopBar {
    topbarIndex = 0;
    labelMakes = [[NSMutableArray alloc] initWithObjects:@"FOLLOWED", @"TRENDING", nil];
    
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
//    self.topbarList.snapToCenter = YES;
    
    [topBarView addSubview:self.topbarList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    mFollowedInitialized = false;
    mTrendingInitialized = false;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isFromDetail){
        isFromDetail = false;
        return;
    }
    
    //banned list
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_FEED_BANNED equalTo:@"true"];
    [query setLimit:QUERY_MAX_LIMIT];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
        if (!error){
            [[AppDataManager instance].bannedArray removeAllObjects];
            for (PFObject *obj in objs){
                [[AppDataManager instance].bannedArray addObject:obj];
            }
            if (!mFollowedInitialized && topbarIndex == 0) {
                [self prepareRefresh];
            } else if (!mTrendingInitialized && topbarIndex == 1) {
                [self prepareRefresh];
            }
            
            
        }
    }];
}

- (void)gotoTrendingView:(NSNotification *)notif {
    [_topbarList setSelectedButtonIndex:1];
    [self selectionList:_topbarList didSelectButtonWithIndex:1]; //select trending
}

- (void)likedInDetail:(NSNotification *) notif {
    NSDictionary *userInfo = [notif userInfo];
    NSString *likedNumber = (NSString *) [userInfo valueForKey:@"likedCount"];
    int news = [likedNumber intValue];
    FeedCell *cell = [_tableView cellForRowAtIndexPath:currentIndex];
    int olds = [cell.lblLikeCount.text intValue];
    if (news != olds){
        [cell.lblLikeCount setText:[NSString stringWithFormat:@"%d", news]];
        [cell.btnLike setSelected:!cell.btnLike.isSelected];
    }
}

- (void)prepareRefresh
{
    self.tableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [refreshControl beginRefreshing];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_FIELD_OBJECT_ID equalTo:[PFUser currentUser].objectId];
    [query setLimit:QUERY_MAX_LIMIT];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error){
            NSMutableArray *tmp = object[PARSE_USER_BLOCKED];
            if (!tmp){
                tmp = [[NSMutableArray alloc] init];
            }
            [AppDataManager instance].blockdedIdArray = tmp;
            if (tmp.count > 0){
                PFQuery *userQuery = [PFUser query];
                [userQuery whereKey:PARSE_FIELD_OBJECT_ID containedIn:tmp];
                [userQuery setLimit:QUERY_MAX_LIMIT];
                [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
                    if (!error && objs.count >0){
                        [blockArray removeAllObjects];
                        [[AppDataManager instance].blockedArray removeAllObjects];
                        for (PFObject *block in objs){
                            [blockArray addObject:block];
                            [[AppDataManager instance].blockedArray addObject:block];
                        }
                        
                    }
                    [self refreshItems];
                }];
            } else {
                [self refreshItems];
            }
            
        }
    }];
}

- (void)refreshItems {
    if (isRefreshing){
        return;
    }
    isRefreshing = true;
    
    if (topbarIndex == 0) { // followed tap selected
        mFollowedInitialized = YES;
        
        PFQuery *followQuery = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
        [followQuery whereKey:PARSE_FOLLOW_FOLLOWING equalTo:[PFUser currentUser]];
        [followQuery includeKey:PARSE_FOLLOW_USER];
        [followQuery setLimit:QUERY_MAX_LIMIT];
        [followQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [followedArray removeAllObjects];
            
            if (!error && objects.count > 0) {
                [[AppDataManager instance].followerArray removeAllObjects];
                for (PFObject *obj in objects) {
                    [[AppDataManager instance].followerArray addObject:obj[PARSE_FOLLOW_USER]];
                }
                
                PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
                [query whereKey:PARSE_FIELD_USER containedIn:[AppDataManager instance].followerArray];
                [query whereKey:PARSE_FIELD_USER notContainedIn:[AppDataManager instance].bannedArray];
                [query whereKey:PARSE_FIELD_USER notContainedIn:blockArray];
                [query whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
                [query includeKey:PARSE_FIELD_USER];
                [query orderByDescending:PARSE_FIELD_CREATED_AT];
                [query setLimit:QUERY_MAX_LIMIT];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
                    isRefreshing = false;
                    [refreshControl endRefreshing];
                    
                    if (objs.count == 0){
                        txtNoFollowed.hidden = NO;
                    } else {
                        txtNoFollowed.hidden = YES;
                    }
                    
                    if (!error) {
                        followedArray = [[NSMutableArray alloc] initWithArray:objs];
                        [self.tableView reloadData];
                    }
                }];
            } else {
                isRefreshing = false;
                txtNoFollowed.hidden = NO;
                [refreshControl endRefreshing];
                [self.tableView reloadData];
            }
        }];
    } else {
//        mTrendingInitialized = YES; //refresh for VIDEO MOMENT
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
        [query whereKey:PARSE_FIELD_USER notContainedIn:[AppDataManager instance].bannedArray];
        [query includeKey:PARSE_FIELD_USER];
        [query whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
        [query whereKey:PARSE_FIELD_USER notContainedIn:blockArray];
        [query orderByDescending:PARSE_FEED_TREND_COUNT];
        [query orderByDescending:PARSE_FIELD_CREATED_AT];
        [query setLimit:QUERY_MAX_LIMIT];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
            isRefreshing = false;
            [refreshControl endRefreshing];
            
            if (!error) {
                trendingArray = [[NSMutableArray alloc] initWithArray:objs];
                [self.tableView reloadData];
            }
        }];
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
    if (topbarIndex != index && !isRefreshing) {
        topbarIndex = index;
        
        if (!mFollowedInitialized && topbarIndex == 0) {
            self.tableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
            [refreshControl beginRefreshing];
            [self refreshItems];
        } else if (!mTrendingInitialized && topbarIndex == 1) {
            txtNoFollowed.hidden = YES;
            self.tableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
            [refreshControl beginRefreshing];
            [self refreshItems];
        } else {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (topbarIndex == 0){
        if (followedArray.count == 0){
            txtNoFollowed.hidden = NO;
        } else {
            txtNoFollowed.hidden = YES;
        }
    } else {
        txtNoFollowed.hidden = YES;
    }
    return (topbarIndex == 0) ? followedArray.count : trendingArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    
    @try {
        PFObject *feed = (topbarIndex == 0) ? followedArray[indexPath.row] : trendingArray[indexPath.row];
        [cell setData:feed];
        cell.delegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 170.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndex = indexPath;
    [self performSegueWithIdentifier:@"detailSegue" sender:self];
}

#pragma feedCell delegate
- (void)onLikeFeed:(FeedCell *)cell liked:(BOOL)liked {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // show result before save
    int likeCount = [cell.lblLikeCount.text intValue];
    
    [cell.btnLike setSelected:!liked];
    if (liked) {
        [cell.lblLikeCount setText:[NSString stringWithFormat:@"%d", likeCount - 1]];
    } else {
        [cell.lblLikeCount setText:[NSString stringWithFormat:@"%d", likeCount + 1]];
    }
    // save
    PFObject *feed = (topbarIndex == 0) ? followedArray[indexPath.row] : trendingArray[indexPath.row];
    [ParseUtils likeFeed:feed like:!liked withView:self.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        FeedDetailViewController *vc = segue.destinationViewController;
        isFromDetail = true;
        vc.index = -1;
        FeedCell *cell = [_tableView cellForRowAtIndexPath:currentIndex];
        vc.isLiked = cell.btnLike.isSelected;
        vc.feedObject = (topbarIndex == 0) ? followedArray[currentIndex.row] : trendingArray[currentIndex.row];
    }
}

//check full visibility of tableview cell
- (void) checkVisibilityOfCell:(FeedCell *)cell inScrollView:(UIScrollView *) aScrollView
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (topbarIndex == 0){
        if (indexPath.row >= followedArray.count){
            return;
        }
    } else {
        if (indexPath.row >= trendingArray.count){
            return;
        }
    }
    PFObject *feed = (topbarIndex == 0) ? followedArray[indexPath.row] : trendingArray[indexPath.row];
    bool isVideCell = (feed[PARSE_FEED_VIDEO]) ? YES:NO;
    CGRect cellRect = [aScrollView convertRect:cell.frame toView:aScrollView.superview];
    
    if (CGRectContainsRect(aScrollView.frame, cellRect)){ // visibi
        FeedCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (isVideCell){
//            if (cell.avplayer != nil) { //playing
//                [cell.avplayer play];
//            }
        }
    } else {
        if (isVideCell){
//            FeedCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//            [cell seekToStart];
        }
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *cells = self.tableView.visibleCells;
    
    NSUInteger cellCount = [cells count];
    if (cellCount == 0){
        return;
    }
    
    //check the visibility of the video cell
    for (NSUInteger i=0;i<cellCount;i++){
        FeedCell *cell = [cells objectAtIndex:i];
        [self checkVisibilityOfCell:cell inScrollView:scrollView];
    }
}

@end
