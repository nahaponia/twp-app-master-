//
//  MyProfileViewController.m
//  SportWorldPassport
//
//  Created by star on 1/8/16.
//  Copyright (c) 2016 UWP. All rights reserved.
//

#import "MyProfileViewController.h"
#import "EditPostViewController.h"

#import "MyFeedCell.h"
#import "MGSwipeButton.h"
#import "ParseUtils.h"

@interface MyProfileViewController () <UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate, EditPostDelegate>
{
    IBOutlet CircleImageView *avatarImageView;
    IBOutlet UILabel *lblFullName;
    IBOutlet UILabel *lblUsername;
    IBOutlet UILabel *lblDescription;
    IBOutlet UILabel *lblPostCounts;
    IBOutlet UILabel *lblFollowers;
    IBOutlet UILabel *lblFollowings;
    IBOutlet UITableView *feedTableView;
    
    IBOutlet UIView *leftView;
    IBOutlet UIView *rightView;
    
    NSIndexPath *currentIndex;
    NSMutableArray *feedArray;
    PFUser *me;
}

- (IBAction)onBack:(id)sender;
@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
    // set profile data
    [ParseUtils setParsePictureOf:avatarImageView file:me[PARSE_USER_AVATAR] default:nil];
    lblFullName.text = [NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FIRSTNAME], me[PARSE_USER_LASTNAME]];
    lblUsername.text = [NSString stringWithFormat:@"@%@", me.username];
    lblPostCounts.text = [NSString stringWithFormat:@"%d", [me[PARSE_USER_POST_COUNT] intValue]];

    feedArray = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadFeedData];
}

- (void)loadFeedData {
    // fetch post data
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
    [query whereKey:PARSE_FIELD_USER equalTo:me];
    [query whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [query setLimit:QUERY_MAX_LIMIT];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects) {
            feedArray = [[NSMutableArray alloc] initWithArray:objects];
            [feedTableView reloadData];
        }
    }];
    
    // fetch following counts and follower counts
    
    PFQuery *postQuery = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
    [postQuery whereKey:PARSE_FIELD_USER equalTo:me];
    [postQuery whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
    
    [postQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            int postCount = [me[PARSE_USER_POST_COUNT] intValue];
            if (number != postCount) {
                lblPostCounts.text = [NSString stringWithFormat:@"%d", number];
                
                me[PARSE_USER_POST_COUNT] = [NSNumber numberWithInt:number];
                [me saveInBackground];
            }
        }
    }];
    
    PFQuery *followerQuery = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [followerQuery whereKey:PARSE_FIELD_USER equalTo:me];
    [followerQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            lblFollowers.text = [NSString stringWithFormat:@"%d", number];
        }
    }];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [followingQuery whereKey:PARSE_FOLLOW_FOLLOWING equalTo:me];
    [followingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            lblFollowings.text = [NSString stringWithFormat:@"%d", number];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (feedArray == 0){
        leftView.hidden = YES;
        rightView.hidden = YES;
    }
    return feedArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    
    PFObject *feed = feedArray[indexPath.row];
    [cell setData:feed];
    
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    cell.delegate = self;
    cell.allowsMultipleSwipe = NO;
    
    cell.rightExpansion.fillOnTrigger = NO;
    cell.rightButtons = [self createRightButtons:1];
    
    cell.leftExpansion.fillOnTrigger = NO;
    cell.leftButtons = [self createLeftButtons:1];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 170;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    ExportSheetViewController *vc = (ExportSheetViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ExportSheetViewController"];
//    CompanyModel *model = companyArray[indexPath.row];
//    
//    vc.company = model;
//    vc.sheetArray = [DBHelper getSheetsOfPO:model.index];
//    
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        leftView.hidden = NO;
        rightView.hidden = NO;
    }
}

- (NSArray *)createLeftButtons:(int)number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"  Edit   ", @" Delete "};
    UIColor * colors[2] = {COLOR_BLUE_LIGHT, COLOR_ORANGE};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i % 2] callback:^BOOL(MGSwipeTableCell * sender){
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}

- (NSArray *)createRightButtons:(int)number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@" Delete ", @"  Edit   "};
    UIColor * colors[2] = {COLOR_ORANGE, COLOR_BLUE_LIGHT};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i % 2] callback:^BOOL(MGSwipeTableCell * sender){
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}

- (NSArray *)swipeTableCell:(MGSwipeTableCell *) cell swipeButtonsForDirection:(MGSwipeDirection)direction
              swipeSettings:(MGSwipeSettings *) swipeSettings expansionSettings:(MGSwipeExpansionSettings *) expansionSettings; {
    swipeSettings.transition = MGSwipeTransitionStatic;
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.buttonIndex = -1;
        expansionSettings.fillOnTrigger = NO;
        return [NSMutableArray array];
        //        return [self createRightButtons:2];
    } else {
        expansionSettings.buttonIndex = -1;
        expansionSettings.fillOnTrigger = NO;
        return [NSMutableArray array];
    }
}

- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@", direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    
    currentIndex = [feedTableView indexPathForCell:cell];
    
    if (direction == MGSwipeDirectionRightToLeft) { // delete button
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure to delete this post?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert setTag:TAG_DELETE];
        [alert show];
        return NO; //Don't autohide to improve delete expansion animation
    } else if (direction == MGSwipeDirectionLeftToRight) { // edit button
        [self editFeed];
    }
    
    return YES;
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState) state gestureIsActive:(BOOL) gestureIsActive
{
    NSLog(@"Changed");
    
    [UIView animateWithDuration:0.5 animations:^{
        [leftView setAlpha:0.0];
        [rightView setAlpha:0.0];
    } completion:^(BOOL finished) {
    }];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /* left view */
    CGRect frame = leftView.frame;
    frame.origin.x = -leftView.frame.size.width;
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        leftView.frame = frame;
    } completion:^(BOOL finished){
        
    }];
    
    /* right view */	
    frame.origin.x = self.view.frame.size.width;
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        rightView.frame = frame;
    } completion:^(BOOL finished){
        
    }];
}


- (void)editFeed {
    EditPostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPostViewController"];
    vc.postObject = feedArray[currentIndex.row];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didChangedPost:(PFObject *)object {
    PFObject *curItem = feedArray[currentIndex.row];
    if ([curItem.objectId isEqualToString:object.objectId]) {
        [feedTableView reloadRowsAtIndexPaths:@[currentIndex] withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)deleteFeed {
    PFObject *feed = feedArray[currentIndex.row];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // delete notifications in the news Table
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NEWS];
    [query whereKey:PARSE_NEWS_FEED equalTo:feed];
    [query includeKey:PARSE_NEWS_FEED];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (!error){
            for (PFObject *item in array){
                [item delete];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [CommonUtils showAlertView:@"Error" message:error.description delegate:self tag:TAG_ERROR];
        }
    }];
    
    [feed deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            PFUser *curUser = [PFUser currentUser];
            int postCount = [curUser[PARSE_USER_POST_COUNT] intValue];
            postCount --;
            curUser[PARSE_USER_POST_COUNT] = [NSNumber numberWithInt:postCount];
            [curUser saveInBackground];
            
            lblPostCounts.text = [NSString stringWithFormat:@"%d", postCount];
            
            [feedArray removeObjectAtIndex:currentIndex.row];
            [feedTableView deleteRowsAtIndexPaths:@[currentIndex] withRowAnimation:UITableViewRowAnimationRight];
        }
    }];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSInteger tag = [alertView tag];
    if (tag == TAG_DELETE) {
        if (buttonIndex == 1) {
            [self deleteFeed];
        }
    }
}

@end
