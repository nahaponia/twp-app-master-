//
//  StampViewController.m
//  SportWorldPassport
//
//  Created by developer on 06/07/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "OperationViewController.h"
#import "StampViewController.h"
#import "CreateStampViewController.h"
#import "EditPhotoViewController.h"
#import "PrintStampOneViewController.h"
#import "UIImage+Convenience.h"

@implementation StampViewController
@synthesize mGalleryView, mLblSelected, mBtnEdit, mBtnPay, currentIndexPath;

NSMutableArray *selectedIndex;

- (void)viewDidLoad{
    [self initialize];
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 3.0;
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.mGalleryView addGestureRecognizer:lpgr];

}

- (void)initialize {

    stampArray = [[NSMutableArray alloc] init];

    [self.mLblTheme setText:@"selected"];
    [self.mLblSelected setHidden:false];
    [self.mLblSufix setHidden:false];
    [self.mLblSelected setText:@"0"];
    [self.mLblSufix setText:@"/12"];
    [mBtnEdit setImage:[UIImage imageNamed:@"ic_edit"] forState:UIControlStateNormal];

    selectedIndex = [[NSMutableArray alloc] init];
    [mBtnPay setEnabled:false];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFUser *me = [PFUser currentUser];
    if (![[me[PARSE_FEED_BANNED] lowercaseString] isEqualToString:@"true"]){
        [self loadItems];
    }
}

- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onCreatePressed:(id)sender {
    CreateStampViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateStampViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadItems {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_STAMP];
    [query whereKey:PARSE_STAMP_USER equalTo:[PFUser currentUser]];
    [query includeKey:PARSE_STAMP_FEED];
    [query setLimit:QUERY_MAX_LIMIT];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error && objects.count > 0) {
            [stampArray removeAllObjects];
            for (PFObject *obj in objects) {
                [stampArray addObject:obj];
            }
        }
        [mGalleryView reloadData];
    }];
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return stampArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellStamp" forIndexPath:indexPath];
    
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:1];
    UILabel *label = (UILabel *)[cell viewWithTag:2]; //text
    UILabel *lblLocation = (UILabel *)[cell viewWithTag:3]; //location
    UIImageView *icon = (UIImageView *)[cell viewWithTag:4];
    
    PFObject *object = stampArray[indexPath.row];
    PFFile *feed = object[PARSE_STAMP_FILE];
    
//    label.text = object[@"text"];
//    label.textColor = [CommonUtils colorWithHexString:object[@"fontcolor"]];
//    label.font = [UIFont fontWithName:object[@"fonttype"] size:label.font.pointSize];
//    lblLocation.text = object[PARSE_FEED_LOCATION];
//    if (lblLocation.text == nil || [lblLocation.text isEqualToString:@""]){
//        icon.hidden = YES;
//    } else {
//        icon.hidden = NO;
//    }
    [ParseUtils setParsePictureOf:imgView file:feed default:nil];
    
    cell.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    if ([self isNewSelected:indexPath.row] == false){
        cell.layer.borderColor = [UIColor greenColor].CGColor;
        cell.layer.borderWidth = 5;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = mGalleryView.bounds.size.width / 4;
    CGSize size = CGSizeMake(width, width);
    return size;
    
    }

#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if ([selectedIndex count] == 12){
        return;
    }

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    cell.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    if ([self isNewSelected:indexPath.row]){
        cell.layer.borderColor = [UIColor greenColor].CGColor;
        cell.layer.borderWidth = 5;
        
        [selectedIndex addObject:[NSNumber numberWithInteger:indexPath.row]];
        currentIndexPath = indexPath;
    } else {
        [selectedIndex removeObject:[NSNumber numberWithInteger:indexPath.row]];
    }
    
    [self showPrintView];

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

// IBActions
- (IBAction)onEditClicked:(id)sender {
    [self onEditOrDeselectAll];
}
- (IBAction)onPrevClicked:(id)sender {
    UIImage *image = [UIImage imageWithView:self.view];

    OperationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OperationViewController"];
    vc.bgImage = image;
    
    NSMutableArray *selectedStampArray;
    selectedStampArray = [[NSMutableArray alloc] init];
    
    for (int i = 0;i<[selectedIndex count];i++){
        int num = [[selectedIndex objectAtIndex:i] integerValue];
        PFObject *obj = stampArray[num];
        [selectedStampArray addObject:obj];
    }
    [selectedIndex removeAllObjects];
    
    vc.stampArray = selectedStampArray;
    [self presentViewController:vc animated:YES completion:^{
    }];
}

- (IBAction)onPayPrint:(id)sender {
    
    NSMutableArray *selectedStampArray;
    selectedStampArray = [[NSMutableArray alloc] init];
    
    for (int i = 0;i<[selectedIndex count];i++){
        int num = [[selectedIndex objectAtIndex:i] integerValue];
        PFObject *obj = stampArray[num];
        [selectedStampArray addObject:obj];
    }
    [selectedIndex removeAllObjects];
    [self showPrintView];
    [mGalleryView reloadData];
    
    PrintStampOneViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PrintStampOneViewController"];
    vc.stampArray = selectedStampArray;
    [self.navigationController pushViewController:vc animated:YES];
}

// functions
- (void) onEditOrDeselectAll {
    if ([selectedIndex count] == 1){ // edit
        EditPhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPhotoViewController"];
        PFObject *object = [stampArray objectAtIndex:[[selectedIndex objectAtIndex:0] integerValue]];
        vc.stampObject = object;
        
//        UICollectionViewCell *cell = [mGalleryView cellForItemAtIndexPath:currentIndexPath];
//        UIImageView *imgView = (UIImageView *) [cell viewWithTag:1];
//        vc.image = imgView.image;
        
        PFFile *file = object[PARSE_STAMP_FILE];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIImage *ima = [UIImage imageWithData:data];
            vc.image = ima;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    } else { // deselect all
        
        [selectedIndex removeAllObjects];
        [self showPrintView];
        [mGalleryView reloadData];
    }
}

- (void)showPrintView {
    if ([selectedIndex count] > 1)
        [mBtnEdit setImage:[UIImage imageNamed:@"ic_disselect"] forState:UIControlStateNormal];
    else
        [mBtnEdit setImage:[UIImage imageNamed:@"ic_edit"] forState:UIControlStateNormal];
    
    if ([selectedIndex count] != 12) {
        [self.mLblSelected setHidden:false];
        [mLblSelected setText:[NSString stringWithFormat:@" %lu", (unsigned long)([selectedIndex count])]];
        [self.mLblSufix setHidden:false];
        [self.mLblTheme setText:@"selected"];
        [mBtnPay setEnabled:false];
    } else {
        [self.mLblSelected setHidden:true];
        [self.mLblSufix setHidden:true];
        [self.mLblTheme setText:@"print for 7$"];
        [mBtnPay setEnabled:true];
    }
}

- (BOOL) isNewSelected:(int)rowNum {
    for (int i = 0;i<[selectedIndex count];i++){
        int num = [[selectedIndex objectAtIndex:i] integerValue];
        if (rowNum == num){
            return false;
        }
    }
    return true;
}

- (void) gotoEditViewController {
    
}

- (void) gotoPrintViewController {
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.mGalleryView];
    
    NSIndexPath *indexPath = [self.mGalleryView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
//        UICollectionViewCell* cell = [self.mGalleryView cellForItemAtIndexPath:indexPath];
        // do stuff with the cell
        
        [selectedIndex removeAllObjects];
        [selectedIndex addObject:[NSNumber numberWithInteger:indexPath.row]];
        [self showPrintView];
        [mGalleryView reloadData];
        
        EditPhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPhotoViewController"];
        vc.stampObject = [stampArray objectAtIndex:[[selectedIndex objectAtIndex:0] integerValue]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
