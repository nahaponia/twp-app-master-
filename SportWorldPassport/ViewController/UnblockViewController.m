//
//  UnblockViewController.m
//  SportWorldPassport
//
//  Created by Developer on 9/4/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "UnblockViewController.h"
#import "ProfileViewController.h"
#import "UserOperationViewController.h"
#import "UIImage+Convenience.h"
#import "AppDataManager.h"

NSMutableArray *blockedArray;
@implementation UnblockViewController
@synthesize userTableView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    blockedArray = [[NSMutableArray alloc] init];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void) refreshData
{
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
                        [blockedArray removeAllObjects];
                        [[AppDataManager instance].blockedArray removeAllObjects];
                        for (PFObject *block in objs){
                            [blockedArray addObject:block];
                            [[AppDataManager instance].blockedArray addObject:block];
                        }
                    }
                    [userTableView reloadData];
                }];
            } else {
                [userTableView reloadData];
            }
        }
    }];

}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return blockedArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    UIImageView *avatar = (UIImageView *)[cell viewWithTag:100];
    UILabel *lblName = (UILabel *)[cell viewWithTag:101];
    UILabel *lblFullName = (UILabel *)[cell viewWithTag:102];
    
    PFUser *user = blockedArray[indexPath.row];
    [ParseUtils setParsePictureOf:avatar file:user[PARSE_USER_AVATAR] default:nil];
    lblName.text = user.username;
    lblFullName.text = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTNAME]];
    return  cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserOperationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserOperationViewController"];
    vc.bgImage = [UIImage imageWithView:self.view];
    vc.user = blockedArray[indexPath.row];
    vc.isBlocking = NO;
    [self.navigationController pushViewController:vc animated:NO];
}
- (IBAction)onDone:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
