//
//  CreateStampViewController.m
//  SportWorldPassport
//
//  Created by developer on 07/07/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "CreateStampViewController.h"
#import "CreateOneStampViewController.h"

#import "UIImage+Convenience.h"

@interface CreateStampViewController ()
{
    IBOutlet UICollectionView *mStampsView;
    
    NSIndexPath *currentIndex;
    NSMutableArray *feedArray;
    PFUser *me;
}

@end

@implementation CreateStampViewController

- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    me = [PFUser currentUser];
    
    feedArray = [[NSMutableArray alloc] init];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[me[PARSE_FEED_BANNED] lowercaseString] isEqualToString:@"true"]){
        [self loadFeedData];
    }
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
            [mStampsView reloadData];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return feedArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellStamp" forIndexPath:indexPath];
    
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:1];
    
    PFObject *feed = feedArray[indexPath.row];
    [ParseUtils setParsePictureOf:imgView file:feed[PARSE_FEED_SMALL_PHOTO] default:nil];
    
//    if (indexPath == currentIndex) {
//        cell.layer.borderColor = [UIColor greenColor].CGColor;
//        cell.layer.borderWidth = 5;
//    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = mStampsView.bounds.size.width / 4;
    CGSize size = CGSizeMake(width, width);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    currentIndex = indexPath;
    
    CreateOneStampViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateOneStampViewController"];
    vc.feedObject = feedArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
