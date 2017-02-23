//
//  PrintStampTreeViewController.m
//  SportWorldPassport
//
//  Created by User 10 on 7/16/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "PrintStampTreeViewController.h"
#import "StampViewController.h"
#import "UIImage+Convenience.h"
#import "DeliveryAndBillingModel.h"
#import "CollageCollectionViewCell.h"
#import <UIImageView+WebCache.h>

@interface PrintStampTreeViewController ()

@property (nonatomic, strong) UIView *collageContainerView;
@property (nonatomic, strong) UIImageView *templateImageView;
@property (nonatomic, strong) UICollectionView *photosCollectionView;

@end

@implementation PrintStampTreeViewController
@synthesize stampArray, mGalleryView, mView, model;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //isFirst = YES;
    
    self.templateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stamps_bg.png"]];
    self.collageContainerView = [[UIView alloc] initWithFrame:self.templateImageView.bounds];
    self.collageContainerView.layer.borderColor = [UIColor grayColor].CGColor;
    self.collageContainerView.layer.borderWidth = 1;
    
    [self.collageContainerView addSubview:self.templateImageView];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 6;
    self.photosCollectionView = [[UICollectionView alloc] initWithFrame:self.collageContainerView.bounds collectionViewLayout:layout];
    self.photosCollectionView.dataSource = self;
    self.photosCollectionView.delegate = self;
    self.photosCollectionView.backgroundColor = [UIColor clearColor];
    [self.photosCollectionView registerNib:[UINib nibWithNibName:@"CollageCollectionViewCell" bundle:nil]
                forCellWithReuseIdentifier:[CollageCollectionViewCell reuseIdentifier]];
    
    [self.collageContainerView addSubview:self.photosCollectionView];
    [self.collageContainerView layoutIfNeeded];
    
    mView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.photosCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDonePressed:(id)sender {
    //isFirst = NO;
    [self makeStampTemplate];
    [self goToChooseStamps];
}

- (void)goToChooseStamps {
    
    NSLog(@"self.navigationController.viewControllers.count :%@", self.navigationController.viewControllers);
    for (int i=0; i < self.navigationController.viewControllers.count; i++) {
        if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[StampViewController class]]) {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:YES];
            return;
        }
    }
}

- (void) makeStampTemplate {
    //make template
    UIGraphicsBeginImageContextWithOptions(self.collageContainerView.bounds.size, self.collageContainerView.opaque, 1.0);
    self.collageContainerView.layer.shouldRasterize = YES;
    self.collageContainerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.collageContainerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
//    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil); //save to camera roll
    UIGraphicsEndImageContext();
    
    //send email to manager
    NSData *template = UIImageJPEGRepresentation(img, 0.85);
    UIImage *newImage = [img getCroppedImage:IMAGE_SIZE_NORMAL height:IMAGE_SIZE_NORMAL * img.size.height / img.size.width];

    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_FEED];
    object[PARSE_FIELD_USER]        = [PFUser currentUser];
    object[PARSE_FEED_TITLE]        = @"template";
    object[PARSE_FEED_DESCRIPT]     = @"template";
    object[PARSE_FEED_TAGS]         = @"template";
    object[PARSE_FEED_NORMAL_PHOTO] = [PFFile fileWithData:template];
    object[PARSE_FEED_SMALL_PHOTO]  = [PFFile fileWithData:UIImagePNGRepresentation(newImage)];
    object[PARSE_FEED_CROP_RATE]    = [NSNumber numberWithInt:100];
    object[PARSE_FEED_LIKES]        = @[];
    object[PARSE_FEED_COMMENTS]     = @[];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FEED];
        [query whereKey:PARSE_STAMP_USER equalTo:[PFUser currentUser]];
        [query whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
        [query whereKey:PARSE_FEED_TITLE equalTo:@"template"];
        [query setLimit:QUERY_MAX_LIMIT];
        [query orderByDescending:PARSE_FIELD_CREATED_AT];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count > 0) {
                PFFile *file = objects[objects.count-1][PARSE_FEED_NORMAL_PHOTO];
                NSString *url = file.url;
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:@"hi@travelworldpassport.com" forKey:@"toEmail"];
                [dic setValue:[PFUser currentUser].email forKey:@"fromEmail"];
                [dic setValue:[NSString stringWithFormat:@"%@ %@", model.firstName, model.lastName] forKey:@"text"];//name
                [dic setValue:@"Stamp Template TravelWorldPassport" forKey:@"subject"];
                [dic setValue:url forKey:@"imageUrlKey"];
                [dic setValue:model.street forKey:@"street"];
                [dic setValue:model.country forKey:@"country"];
                [dic setValue:model.phoneNumber forKey:@"phoneNumber"];
                [dic setValue:@"Total: 7.00 USD" forKey:@"price"];
                [PFCloud callFunctionInBackground:@"mailSend" withParameters:dic block:^(NSString* result, NSError *error){
                    [objects[objects.count-1] delete];
                }];
            }
        }];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Collection view data source



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return stampArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CollageCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:1];
    
    PFObject *object = stampArray[indexPath.row];
    PFFile *feed = object[PARSE_STAMP_FILE];
//    label.text = object[@"text"];
//    lblLocation.text = object[PARSE_STAMP_LOCATION];
//    if (lblLocation.text == nil || [lblLocation.text isEqualToString:@""]){
//        icon.hidden = YES;
//    } else {
//        icon.hidden = NO;
//    }
    
//    label.textColor = [CommonUtils colorWithHexString:object[@"fontcolor"]];
//    label.font = [UIFont fontWithName:object[@"fonttype"] size:label.font.pointSize];
    [imgView sd_setImageWithURL:[NSURL URLWithString:feed.url] placeholderImage:nil];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = self.templateImageView.bounds.size.width / 4 - 5;
    CGFloat height = self.templateImageView.bounds.size.height / 3 - 1;
    CGSize size = CGSizeMake(width, height);
    return size;
}

@end
