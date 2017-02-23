//
//  PrintStampTwoViewController.m
//  SportWorldPassport
//
//  Created by User 10 on 7/16/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <Stripe/Stripe.h>

#import "PrintStampTwoViewController.h"
#import "PrintStampTreeViewController.h"
#import "DeliveryAndBillingModel.h"

typedef NS_ENUM(NSInteger, STPBackendChargeResult) {
    STPBackendChargeResultSuccess,
    STPBackendChargeResultFailure,
};

typedef void (^STPTokenSubmissionHandler)(STPBackendChargeResult status, NSError *error);

@protocol STPBackendCharging <NSObject>

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion;

@end

@interface PrintStampTwoViewController () <STPBackendCharging>
{
    IBOutlet UILabel *lblUserName;
    IBOutlet UILabel *lblStreet;
    IBOutlet UILabel *lblCountry;
    IBOutlet UILabel *lblCityAndPostCode;
    IBOutlet UILabel *lblCardNumber;
    IBOutlet UILabel *lblExpireDate;
    IBOutlet UILabel *lblCVV;
    IBOutlet UILabel *lblPhoneNumber;
    
    IBOutlet UICollectionView *mStampsView;
    
}

@end

@implementation PrintStampTwoViewController

@synthesize model;
@synthesize stripeToken;
@synthesize stampArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [mStampsView reloadData];
    
    lblUserName.text = [NSString stringWithFormat:@"%@ %@", model.firstName, model.lastName];
    lblStreet.text = model.street;
    lblCountry.text = model.country;
    lblCityAndPostCode.text = [NSString stringWithFormat:@"%@ %@", model.city, model.postcode];
    lblPhoneNumber.text = model.phoneNumber;
    
    lblCardNumber.text = model.cardNumber;
    lblExpireDate.text = model.expireDate;
    lblCVV.text = model.cvv;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)onConfirmAndBuyPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self createBackendChargeWithToken:stripeToken
                            completion:^(STPBackendChargeResult result, NSError *error) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^(void) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if (error) {
                                        [CommonUtils showAlertView:TITLE_ERROR message:[error localizedDescription] delegate:nil tag:TAG_ERROR];
                                        return;
                                    }
                                    
                                    PrintStampTreeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PrintStampTreeViewController"];
                                    vc.stampArray = stampArray;
                                    vc.model = model;
                                    [self.navigationController pushViewController:vc animated:YES];
                                });
                            }];
    
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return stampArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellStamp" forIndexPath:indexPath];
    
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:1];
    
    PFObject *object = stampArray[indexPath.row];
    PFObject *feed = object[PARSE_STAMP_FEED];
    [ParseUtils setParsePictureOf:imgView file:feed[PARSE_FEED_SMALL_PHOTO] default:nil];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = mStampsView.bounds.size.height;
    CGSize size = CGSizeMake(width, width);
    return size;
    
}

#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (isPrintView){
//        return;
//    }
//    
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.layer.borderColor = [UIColor greenColor].CGColor;
//    cell.layer.borderWidth = 5;
//    
//    if ([self isNewSelected:indexPath.row]){
//        [selectedIndex addObject:[NSNumber numberWithInteger:indexPath.row]];
//        [mLblSelected setText:[NSString stringWithFormat:@" %lu", (unsigned long)([selectedIndex count])]];
//        if ([selectedIndex count] == 12){
//            [self changeToPrintView];
//        }
//    }
    
}

#pragma mark - STPBackendCharging

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    
    if (!BackendChargeURLString) {
        NSError *error = [NSError
                          errorWithDomain:StripeDomain
                          code:STPInvalidRequestError
                          userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                                                 @"instructions in the README to set up an example backend, or use this "
                                                                 @"token to manually create charges at dashboard.stripe.com .",
                                                                 token.tokenId]
                                     }];
        completion(STPBackendChargeResultFailure, error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSString *urlString = [BackendChargeURLString stringByAppendingPathComponent:@"charge"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    PFObject *user = [PFUser currentUser];
    NSString *username = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTNAME]];
    username = lblUserName.text;
    NSString *description = [NSString stringWithFormat:@"%@ - %@", username, @"SWP APP STMAPS"];
    NSString *postBody = [NSString stringWithFormat:@"stripeToken=%@&amount=%@&description=%@", token.tokenId, @700, description];
    NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:data
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                          if (!error && httpResponse.statusCode != 200) {
                                                              error = [NSError errorWithDomain:StripeDomain
                                                                                          code:STPInvalidRequestError
                                                                                      userInfo:@{NSLocalizedDescriptionKey: @"There was an error connecting to your payment backend."}];
                                                          }
                                                          if (error) {
                                                              completion(STPBackendChargeResultFailure, error);
                                                          } else {
                                                              completion(STPBackendChargeResultSuccess, nil);
                                                          }
                                                      }];
    
    [uploadTask resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
